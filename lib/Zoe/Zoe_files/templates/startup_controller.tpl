
package    #__PACKAGENAME__;

use Mojo::Base 'Mojolicious';
use Mojolicious::Plugin::Config;
use Zoe::Runtime;
use YAML::XS;
use Data::Dumper;

use Zoe::AuthorizationManager;

#custom helpers
use Zoe::Helpers;
use Zoe::DataObject;

use File::Basename 'dirname';
use Path::Class;
use Carp;
use Mojo::Log;

#runtime
my $runtime;

###############
#Application models

#__USESTATEMENTS__


# This method will run once at server start
sub startup {
    my $self = shift;
    my %OBJECT_FOR_URL = ();

    #returns path to the config dir
    $self->helper(
            get_config_dir => sub {
               return 
                  dir( dirname(__FILE__), '..', 'config',   );
               
            }
        );      
    #returns path to the import backup  up  dir
    $self->helper(
    		get_import_backup_dir => sub {
               return 
                  dir( dirname(__FILE__), '..', '..', 'yaml', 'import'   );
               
            }
        );      
    #returns path to the import backup  up  dir
    $self->helper(
    		get_runtime_backup_dir => sub {
               return 
                  dir( dirname(__FILE__), '..', '..', 'yaml', 'runtime'   );
               
            }
        );   
    
    #returns path to the startup script  
    $self->helper(
    		get_startup_script => sub {
               return 
               file ( dirname(__FILE__), '..', 'script','#__STARTUPSCRIPT__'   );
               
            }
        );
    
    #returns path to the import backup  up  dir
    $self->helper(
    		get_lib_dir => sub {
               return 
               dir ( dirname(__FILE__), '..', 'lib',   );
               
            }
        );
    
    #   Runtime
    #   Reads runtime.yml and return as Zoe::Runtime
    $self->helper(
        get_runtime => sub {
            my $runtime_yml =
              file( dirname(__FILE__), '..', 'config', 'runtime.yml' );
            if ( -e $runtime_yml ) {
                my $runtime_config = 0;
                return $runtime_config = YAML::XS::LoadFile($runtime_yml)
                  or croak " FATAL YAML Parse error in $runtime_yml";
                  
               
            }

            return 0;
        }
    );  
    
    $runtime =  $self->get_runtime();    

    #environment variables
    #__ENVIRONMENTVAR__
    $ENV{MOJO_REVERSE_PROXY} = 1;
    $ENV{ZOE_APP_LIB} = dirname(__FILE__);

    #set the mode so the correct db entry is read from config file
    unless ( defined( $ENV{ZOE_ENV} ) ) {

        $ENV{ZOE_ENV} = ( $ENV{MOJO_MODE} or 'development' );
    }


    
    Zoe::DataObject->new( runtime => $runtime, );    
    

    # Documentation browser under "/perldoc"
    $self->plugin('PODRenderer');
    $self->plugin('Zoe::Helpers');
    $self->plugin('DefaultHelpers');

    # Return prefix for crud pages
    $self->helper(
        get_prefix => sub {
            my $c = shift;            
            return '/#__URLPREFIX__'; 
        
        }
    );


    # Return a logger instance
    $self->helper(
        get_logger => sub {
            my $c = shift;
            my $which = shift || 'app';
            my $file_name = $which . '.log';
            my $log_file =
              file( dirname(__FILE__), '..', 'log', $file_name );
            return Mojo::Log->new(path => "$log_file"); 
        
        }
    );
    
    #log
    
    $self->helper(
        log => sub {
            my $self    = shift;
            my $caller  = ( caller(1) )[3];
            my $message = __PACKAGE__ . ':' . $caller . ': ' . shift;
            my $method  = shift || 'debug';
            
            
            my $logger  = $self->get_logger();
            return $logger->$method($message);
    
        }
    );
    
    #get portal portal
    
    $self->helper(
        get_portal => sub {
            my $self    = shift;
            my $runtime = $self->get_runtime();
            
            my $portals  = $runtime->{portals} || [] ;
            my $portal_name = $self->stash('portal');
            
            foreach my $portal (@{$portals}) {
            	return $portal if ($portal_name eq $portal->{name});
            }
            
            return ;
    
        }
    );
        
    #   Authorization
    #   Read authorization file auth.yml return as hash
    $self->helper(
        get_auth_config => sub {
            
            return $runtime->{authorization};
        }
    );
    

  
    
    
#   Paypal
#   Read paypal conf
    $self->helper(
        get_paypal_config => sub {
           return $runtime->{pay_pal};
        }
    );

    $self->hook(
        before_dispatch => sub {
            my $c           = shift;
            my $auth_config = $c->get_auth_config();
            return 1 unless ($auth_config);
            my $auth_success =
              Zoe::AuthorizationManager->new($auth_config)->do_check($c);
            if ($auth_success) {
                return 1;
            }
            else {
                #authorization failed; if logged in redirect_to Not authorized
                my $user_id     = $c->session($auth_config->{user_session_key}) || 0;
                my $redirect_name = '__SHOWLOGIN__';
                 
                $redirect_name = '__NOTAUTHORIZED__' if $user_id;
                my $requested_url = $c->req->url;
                my $redirect_to =
                  $c->url_with($redirect_name)
                  ->query( [ requested_url => $requested_url ] );
                $c->redirect_to($redirect_to);
            }

        }
    );

    #call helper and set auth_config
    my $auth_config = $self->get_auth_config();
    #Add the login routes
    # Router
    my $r = $self->routes;
    if ($auth_config) {
        my $login_controller  = $auth_config->{login_controller};
        my $login_show_method = $auth_config->{login_show_method};
        my $login_do_method   = $auth_config->{login_do_method};

        my $logout_controller = $auth_config->{logout_controller};
        my $logout_do_method  = $auth_config->{logout_do_method};

        $r->get( $auth_config->{login_path} )->name("__SHOWLOGIN__")->to(
            action    => "$login_show_method",
            namespace => "$login_controller",
        );
        $r->post( $auth_config->{login_path} )->name("__DOLOGIN__")->to(
            action    => "$login_do_method",
            namespace => "$login_controller",
        );
        $r->any( $auth_config->{logout_path} )->name("__DOLOGOUT__")->to(
            action    => "$logout_do_method",
            namespace => "$logout_controller",
        );
        $r->any( '/__NOTAUTHORIZED__' )->name("__NOTAUTHORIZED__")->to(
            action    => "log_not_authorized",
            namespace => "Zoe::ZoeController",
        );

    }
    
    #set paypal routes  
    my $paypal_config = $self->get_paypal_config();
    
    if ( $paypal_config ) {
        my $method ='any';
       #add to cart
       $r->$method('/__ADDTOCART__')->name('__ADDTOCART__')
              ->to( namespace => 'Zoe::PayPayTransactionController', action => 'add_to_cart' );      
              
        #empty cart
       $r->$method('/__EMPTYCART__')->name('__EMPTYCART__')
              ->to( namespace => 'Zoe::PayPayTransactionController', action => 'empty_cart' );          
       #remove from cart
       $r->$method('/__REMOVEFROMCART__')->name('__REMOVEFROMCART__')
              ->to( namespace => 'Zoe::PayPayTransactionController', action => 'remove_from_cart' ); 
       #view cart
       $r->$method('/__VIEWCART__')->name('__VIEWCART__')
              ->to( namespace => 'Zoe::PayPayTransactionController', action => 'view_cart' );  
       #paypal cancel
       $r->$method('/__PAYPALCANCEL__')->name('__PAYPALCANCEL__')
              ->to( namespace => 'Zoe::PayPayTransactionController', action => 'paypal_cancel' );  
       
       #do express checkout
       $r->$method('/__DOEXPRESSCHECKOUT__')->name('__DOEXPRESSCHECKOUT__')
              ->to( namespace => 'Zoe::PayPayTransactionController', action => 'do_express_checkout' );  
       
       #set express checkout
       $r->$method('/__SETEXPRESSCHECKOUT__')->name('__SETEXPRESSCHECKOUT__')
              ->to( namespace => 'Zoe::PayPayTransactionController', action => 'set_express_checkout' );        
              
       #update quantity of cart item
       $r->$method('/__UPDATECARTITEMQUANTITY__')->name('__UPDATECARTITEMQUANTITY__')
              ->to( namespace => 'Zoe::PayPayTransactionController', action => 'update_cart_item_quantity' );
       #admin execute transaction
       $r->$method('/__PAYPALTRANSACTION__')->name('__PAYPALTRANSACTION__')
              ->to( namespace => 'Zoe::PayPayTransactionController', action => 'paypal_transaction' );       
                      
       $r->$method('/__REFUNDTRANSACTION__')->name('__REFUNDTRANSACTION__')
              ->to( namespace => 'Zoe::PayPayTransactionController', action => 'refund_transaction' );       
                             
                            
               
    }

   
    $r->any('/#__URLPREFIX__')->to('zoe#welcome');

    #read routes from config
    my $config = "$FindBin::Bin/../config/routes.yml";

    if ( $runtime ) {
        my $routes = $runtime->{routes};
        my @list = ( @{ $routes } );
        
        #add the portals routes 
        my @portal_routes = ();
        if ($runtime->{portals}) {
            foreach my $portal ( @{$runtime->{portals} } ){
            	my $url_prefix = $portal->{url_prefix};
            	$url_prefix .= '/' unless ($url_prefix =~/\/$/);
            	my $portal_name = $portal->{name};
            	my $layout = $portal->{layout};
        
            	foreach my $page (%{$portal->{pages}}){
            		my $path = $url_prefix . $self->{path};
            		my $r = $self->routes;
            		my $method = $page->{method};
                	my $controller = $page->{controller};
                	my $action = $page->{action};
                	my $route_name = $page->{route_name};
            		
                	my $stash = $page->{stash};
                	my %stash = ();
                	%stash = %{$stash} if ($stash);
                	 
                	$r->$method($path)
                		->name($route_name)
                	    ->to( namespace => $controller, action => $action ,
                	    		portal=> $portal_name, 
                	    		page => $route_name,
                	    		layout => $layout,
                	    		
                	    		%stash,);
                	
            	}
            	
            	


            	
              
            }
        }


        foreach my $route ( @list  ) {
            my $method     = $route->{method};
            my $path       = $route->{path};
            my $name       = $route->{name};
            my $controller = $route->{controller};
            my $action     = $route->{action};
            my $type 	   = $route->{type} || 0;

            my $r = $self->routes;
            
            
            $r->$method($path)->name($name)
            	
                ->to( namespace => $controller, action => $action , __TYPE__ => $type,);

        }

    }
    
   
    
    #add save all models route
#    $r->any('//#__URLPREFIX__/__SAVEALLMODELS__/')->name('__SAVEALLMODELS__')
#	->to( namespace =>'Zoe::ZoeController', action =>'save_all_models');
   
       
}
1;
