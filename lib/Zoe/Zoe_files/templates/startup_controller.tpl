
package    #__PACKAGENAME__;

use Mojo::Base 'Mojolicious';
use Mojolicious::Plugin::Config;
use Zoe::Runtime;
use YAML::XS;


use Zoe::AuthorizationManager;

#custom helpers
use Zoe::Helpers;
use Zoe::DataObject;
use YAML::Tiny;
use File::Basename 'dirname';
use Path::Class;
use Carp;
use Mojo::Log;
# This method will run once at server start
sub startup {
    my $self = shift;

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
    
    my $runtime =  $self->get_runtime();    

    #environment variables
    #__ENVIRONMENTVAR__
    $ENV{MOJO_REVERSE_PROXY} = 1;

    #set the mode so the correct db entry is read from config file
    unless ( defined( $ENV{ZOE_ENV} ) ) {

        $ENV{ZOE_ENV} = ( $ENV{MOJO_MODE} or 'development' );
    }

    #set the location for the db.yml file
    #my $db_yml = file( dirname(__FILE__), '..', 'config', 'db.yml' );
    #croak " Could not locate db.yml file: $db_yml" unless ( -e $db_yml );
    #Zoe::DataObject->new( DBCONFIGFILE => $db_yml );

    Zoe::DataObject->new( runtime => $runtime );    
    

    # Documentation browser under "/perldoc"
    $self->plugin('PODRenderer');
    $self->plugin('Zoe::Helpers');
    $self->plugin('DefaultHelpers');


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
    #   Authorization
    #   Read authorization file auth.yml return as hash
    $self->helper(
        get_auth_config => sub {
            my $auth_yml =
              file( dirname(__FILE__), '..', 'config', 'auth.yml' );
            if ( -e $auth_yml ) {
                my $auth_config = 0;
                $auth_config = YAML::Tiny->read($auth_yml)
                  or croak " YAML Parse error in $auth_yml";
                return $auth_config->[0] || 0;
            }

            return 0;
        }
    );
    

  
    
    
#   Paypal
#   Read paypal conf
    $self->helper(
        get_paypal_config => sub {
            my $paypal_yml =
              file( dirname(__FILE__), '..', 'config', 'paypal.yml' );
            if ( -e $paypal_yml ) {
                my $paypal_config = 0;
                $paypal_config = YAML::Tiny->read($paypal_yml)
                  or croak " YAML Parse error in $paypal_yml";
                return $paypal_config->[0] || 0;
            }

            return 0;
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
    $r->any('/#__URLPREFIX__')->to('example#welcome');

    #read routes from config
    my $config = "$FindBin::Bin/../config/routes.yml";

    if ( $runtime ) {
        my $routes = $runtime->{routes};

        foreach my $route ( @{ $routes } ) {
            my $method     = $route->{method};
            my $path       = $route->{path};
            my $name       = $route->{name};
            my $controller = $route->{controller};
            my $action     = $route->{action};

            $r->$method($path)->name($name)
              ->to( namespace => $controller, action => $action );

        }

    }

    #__ROUTES__

}
1;
