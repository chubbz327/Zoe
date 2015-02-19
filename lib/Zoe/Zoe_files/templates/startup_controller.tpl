
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

    #   Runtime
    #   Reads runtime.yml and return as Zoe::Runtime
    $self->helper(
        get_runtime => sub {
            my $runtime_yml =
              file( dirname(__FILE__), '..', 'config', 'runtime.yml' );
            if ( -e $runtime_yml ) {
                my $runtime_config = 0;
                $runtime_config = YAML::XS::LoadFile($runtime_yml)
                  or croak " YAML Parse error in $runtime_yml";
                  
                my $runtime = Zoe::Runtime->new(%$runtime_config);  
                return $runtime || 0;
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
                             
       #payment_complete_route
     #  $r->$method($paypal_config->{payment_complete_route}->{method})
      #      ->name($paypal_config->{payment_complete_route}->{name})
       #       ->to( namespace => $paypal_config->{payment_complete_route}->{controller}, 
        #            action => $paypal_config->{payment_complete_route}->{action} );                              
               
    }

    # Normal route to controller
   # $r->any('/')->to('example#welcome');
    $r->any('/#__URLPREFIX__')->to('zoe#welcome');

    #read routes from config
    my $config = "$FindBin::Bin/../config/routes.yml";

    if ( $runtime ) {
        my $routes = $runtime->{routes};
        my @list = ( @{ $routes } );
        
        #add the sites routes 
        my @site_routes = ();
        if ($runtime->{sites}) {
            foreach my $site ( @{$runtime->{sites} } ){
            	my $site_name = $site->{name};
            	my $site_prefix = $site->{url_prefix};
            	#print Dumper ($site->{models});
            	####default site routes created for every object reference####
            	foreach my $model ( @{$site->{models} }) {
            		my $obj = $model->{name}->new();
            		
            		
            		###show 
            		my $site_route = {};
            		$site_route->{method}=  'get';
            		#$site_route->{path} = sprintf('%s%s\/:id', $site_prefix, $obj->get_object_name_short_hand);  
            		$site_route->{path} = $site_prefix .  $obj->get_object_name_short_hand . '/:id';
            		$site_route->{name} = $site_name . '_show_' . $obj->get_object_name_short_hand;
            		$site_route->{controller} = 'Zoe::SiteController';
            		$site_route->{action} = 'show';  
            		$site_route->{model} =  $obj->{TYPE} ;
            		push (@site_routes, $site_route);
                    
            		
            		##show all 
            		$site_route = {};
            		$site_route->{method}=  'get';
            		#$site_route->{path} = sprintf('%s%s\/:id', $site_prefix, $obj->get_object_name_short_hand);  
            		$site_route->{path} = $site_prefix .  $obj->get_object_name_short_hand;
            		$site_route->{name} = $site_name . '_show_all_' . $obj->get_object_name_short_hand;
            		$site_route->{controller} = 'Zoe::SiteController';
            		$site_route->{action} = 'show_all';  
            		$site_route->{model} = $obj->{TYPE} ;
            		push (@site_routes, $site_route);
            	
                }
            	
                #replace default with Zoe::SiteController                
                foreach my $site_route ( @{$site->{routes} }) {
                	if ( defined ( $site_route->{controller} ) ) {
                		$site_route->{controller} =~ s/__DEFAULT__/Zoe::SiteController/;
                	} else {
                		$site_route->{controller} = 'Zoe::SiteController';
                	}
                	if (  defined($site_route->{action}) ) {
                		$site_route->{action} =~ s/__DEFAULT__/pass_to_handler/;
                	} else {
                		$site_route->{action} = 'pass_to_handler';
                	}
                    push (@site_routes, $site_route);
                }
            }
        }


        foreach my $route ( @list, @site_routes  ) {
            my $method     = $route->{method};
            my $path       = $route->{path};
            my $name       = $route->{name};
            my $controller = $route->{controller};
            my $action     = $route->{action};

            
            
            $r->$method($path)->name($name)
                ->to( namespace => $controller, action => $action , __TYPE__ => $route->{model},);

        }

    }

    
  
    #__ROUTES__
   
}
1;
