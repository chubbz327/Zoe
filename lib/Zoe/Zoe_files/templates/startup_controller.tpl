
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


use FindBin;
BEGIN {
    unshift @INC, "$FindBin::Bin/../app/lib";
}

#runtime
my $runtime;

###############
#Application models

#__USESTATEMENTS__

# This method will run once at server start
sub startup
{
    my $self           = shift;
    #add the application template directory
    push @{$self->renderer->paths},  "$FindBin::Bin/../app/templates";
    
    
    my %OBJECT_FOR_URL = ();

    $self->helper(
        get_user_from_session => sub {
            my $c           = shift;
            my $auth_config = $c->get_auth_config();
            my $__USER__ =
              $c->session( $auth_config->{user_session_key} ) || {};
            $__USER__ = YAML::XS::Load($__USER__)
              if ( $c->session( $auth_config->{user_session_key} ) );

            return $__USER__;
        },
    );

    $self->helper(
        get_role_from_session => sub {
            my $c           = shift;
            my $auth_config = $c->get_auth_config();
            my $__ROLE__    = $c->session( $auth_config->{role_session_key} )
              || { TO_STRING => 'anonymous' };
            $__ROLE__ = YAML::XS::Load($__ROLE__)
              if ( $c->session( $auth_config->{role_session_key} ) );
            return $__ROLE__;

        }
    );

    $self->helper(
        get_admin_role_names => sub {
            my $c           = shift;
            my $auth_config = $c->get_auth_config();
            my $admin_role =
              $auth_config->{config}->{data_object}->{admin_role};
            my $portal = $self->get_portal();
            my $portal_admin_role;
            $portal_admin_role = $portal->{authentication}->{admin_role};
            my @return;
            push( @return, $admin_role );

            push( @return, $portal_admin_role ) if ($portal_admin_role);
            return \@return;

        }
    );

    #returns path to the config dir
    $self->helper(
        get_config_dir => sub {
            return dir( dirname(__FILE__), '..', 'config', );

        },

    );

    #returns path to the import backup  up  dir
    $self->helper(
        get_import_backup_dir => sub {
            return dir( dirname(__FILE__), '..', '..', 'yaml', 'import' );

        }
    );

    #returns path to the import backup  up  dir
    $self->helper(
        get_runtime_backup_dir => sub {
            return dir( dirname(__FILE__), '..', '..', 'yaml', 'runtime' );

        }
    );

    #returns path to the startup script
    $self->helper(
        get_startup_script => sub {
            return file( dirname(__FILE__), '..', 'script',
                         '#__STARTUPSCRIPT__' );

        }
    );

    #returns path to the import backup  up  dir
    $self->helper(
        get_lib_dir => sub {
            return dir( dirname(__FILE__), '..', 'lib', );

        }
    );

    #   Runtime
    #   Reads runtime.yml and return as Zoe::Runtime
    $self->helper(
        get_runtime => sub {
            my $runtime_yml =
              file( dirname(__FILE__), '..', 'config', 'runtime.yml' );
            if ( -e $runtime_yml )
            {
                my $runtime_config = 0;
                return $runtime_config = YAML::XS::LoadFile($runtime_yml)
                  or croak " FATAL YAML Parse error in $runtime_yml";

            }

            return 0;
        }
    );

    $runtime = $self->get_runtime();

    #environment variables
    #__ENVIRONMENTVAR__
    $ENV{MOJO_REVERSE_PROXY} = 1;
    $ENV{ZOE_APP_LIB}        = dirname(__FILE__);

    #set the mode so the correct db entry is read from config file
    unless ( defined( $ENV{ZOE_ENV} ) )
    {

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
            my $c         = shift;
            my $which     = shift || 'app';
            my $file_name = $which . '.log';
            my $log_file  = file( dirname(__FILE__), '..', 'log', $file_name );
            return Mojo::Log->new( path => "$log_file" );

        }
    );

    #log

    $self->helper(
        log => sub {
            my $self    = shift;
            my $caller  = ( caller(1) )[3];
            my $message = __PACKAGE__ . ':' . $caller . ': ' . shift;
            my $method  = shift || 'debug';

            my $logger = $self->get_logger();
            return $logger->$method($message);

        }
    );

    #get portal page

    $self->helper(
        get_page => sub {
            my $self      = shift;
            my $portal    = $self->get_portal();
            my $page_name = $self->stash('page');
            return unless ($page_name);
            foreach my $page ( @{ $portal->{pages} } )
            {
                return $page if ( $page_name eq $page->{name} );
            }

            return;

        }
    );

    #get portal

    $self->helper(
        get_portal => sub {
            my $self    = shift;
            my $runtime = $self->get_runtime();

            my $portals = $runtime->{portals} || [];
            my $portal_name = $self->stash('portal');
            return unless ($portal_name);
            foreach my $portal ( @{$portals} )
            {
                return $portal if ( $portal_name eq $portal->{name} );
            }

            return;

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
        around_action => sub {
            my ( $next, $c, $action, $last ) = @_;
            my $auth_config = $c->get_auth_config();
            my $__USER__    = $c->get_user_from_session();
            return $next->() unless ($auth_config);

            my $auth_success =
              Zoe::AuthorizationManager->new($auth_config)->do_check($c);
            if ($auth_success)
            {

                return $next->();
            } else
            {
                #authorization failed; if logged in redirect_to Not authorized

                my $portal      = $c->get_portal()      || {};
                my $name_prefix = $portal->{url_prefix} || '';
                $name_prefix =~ s/\///gmx;
                my $show_login = $name_prefix . '__SHOWLOGIN__';

                my $redirect_name = '__SHOWLOGIN__';

                $redirect_name = '__NOTAUTHORIZED__' if $__USER__;
                my $requested_url = $c->req->url;
                my $redirect_to =
                  $c->url_with($show_login)
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

#    if ($auth_config)
#    {
#        my $login_controller  = $auth_config->{login_controller};
#        my $login_show_method = $auth_config->{login_show_method};
#        my $login_do_method   = $auth_config->{login_do_method};
#
#        my $logout_controller = $auth_config->{logout_controller};
#        my $logout_do_method  = $auth_config->{logout_do_method};
#
#        $r->get( $auth_config->{login_path} )->name("__SHOWLOGIN__")->to(
#                                               action => "$login_show_method",
#                                               namespace => "$login_controller",
#        );
#        $r->post( $auth_config->{login_path} )->name("__DOLOGIN__")->to(
#                                               action    => "$login_do_method",
#                                               namespace => "$login_controller",
#        );
#        $r->any( $auth_config->{logout_path} )->name("__DOLOGOUT__")->to(
#                                              action    => "$logout_do_method",
#                                              namespace => "$logout_controller",
#        );
#        $r->any('/__NOTAUTHORIZED__')->name("__NOTAUTHORIZED__")->to(
#                                              action    => "log_not_authorized",
#                                              namespace => "Zoe::ZoeController",
#        );
#
#    }

$r->any('/__NOTAUTHORIZED__')->name("__NOTAUTHORIZED__")->to(
                                              action    => "log_not_authorized",
                                              namespace => "Zoe::ZoeController",
       );

    $self->set_auth_routes();

    #set paypal routes
    my $paypal_config = $self->get_paypal_config();

    if ($paypal_config)
    {
        my $method = 'any';

        #add to cart
        $r->$method('/__ADDTOCART__')->name('__ADDTOCART__')->to(
                                namespace => 'Zoe::PayPayTransactionController',
                                action    => 'add_to_cart' );

        #empty cart
        $r->$method('/__EMPTYCART__')->name('__EMPTYCART__')->to(
                                namespace => 'Zoe::PayPayTransactionController',
                                action    => 'empty_cart' );

        #remove from cart
        $r->$method('/__REMOVEFROMCART__')->name('__REMOVEFROMCART__')->to(
                                namespace => 'Zoe::PayPayTransactionController',
                                action    => 'remove_from_cart' );

        #view cart
        $r->$method('/__VIEWCART__')->name('__VIEWCART__')->to(
                                namespace => 'Zoe::PayPayTransactionController',
                                action    => 'view_cart' );

        #paypal cancel
        $r->$method('/__PAYPALCANCEL__')->name('__PAYPALCANCEL__')->to(
                                namespace => 'Zoe::PayPayTransactionController',
                                action    => 'paypal_cancel' );

        #do express checkout
        $r->$method('/__DOEXPRESSCHECKOUT__')->name('__DOEXPRESSCHECKOUT__')
          ->to( namespace => 'Zoe::PayPayTransactionController',
                action    => 'do_express_checkout' );

        #set express checkout
        $r->$method('/__SETEXPRESSCHECKOUT__')->name('__SETEXPRESSCHECKOUT__')
          ->to( namespace => 'Zoe::PayPayTransactionController',
                action    => 'set_express_checkout' );

        #update quantity of cart item
        $r->$method('/__UPDATECARTITEMQUANTITY__')
          ->name('__UPDATECARTITEMQUANTITY__')->to(
                                namespace => 'Zoe::PayPayTransactionController',
                                action    => 'update_cart_item_quantity' );

        #admin execute transaction
        $r->$method('/__PAYPALTRANSACTION__')->name('__PAYPALTRANSACTION__')
          ->to( namespace => 'Zoe::PayPayTransactionController',
                action    => 'paypal_transaction' );

        $r->$method('/__REFUNDTRANSACTION__')->name('__REFUNDTRANSACTION__')
          ->to( namespace => 'Zoe::PayPayTransactionController',
                action    => 'refund_transaction' );

    }

    $r->any('/#__URLPREFIX__')->to('zoe#welcome');

    #read routes from config
    my $config = "$FindBin::Bin/../config/routes.yml";

    if ($runtime)
    {
        my $routes = $runtime->{routes};
        my @list   = ( @{$routes} );

        #add the portals routes
        my @portal_routes = ();
        if ( $runtime->{portals} )
        {
            foreach my $portal ( @{ $runtime->{portals} } )
            {
                my $url_prefix = $portal->{url_prefix};
                $url_prefix .= '/' unless ( $url_prefix =~ /\/$/ );
                my $portal_name = $portal->{name};
                my $layout      = $portal->{layout};

                #set portal search

                my $portal_search = $portal->{search};
                my $limit = $portal_search->{limit} || 10;

                my $path   = $url_prefix . $portal_search->{path};
                my $r      = $self->routes;
                my $method = $portal_search->{method} || 'any';

                my $controller =
                  $portal_search->{controller} || 'Zoe::ZoeController';
                my $action = $portal_search->{action} || 'portal_search';

                my $template = $portal_search->{template};

                my $route_name = $portal_search->{route_name};
                my $stash = $portal_search->{stash};
                    my %stash = ();
                    %stash = %{$stash} if ($stash);
                $r->$method($path)->name($route_name)->to(
                                                       namespace => $controller,
                                                       action    => $action,
                                                       portal   => $portal_name,
                                                       page     => $route_name,
                                                       layout   => $layout,
                                                       template => $template,
                                                       %stash
                );

                if ( $portal->{authentication} )
                {
                    $portal->{authentication}->{stash}->{layout} =
                      $portal->{layout};

                    $portal->{authentication}->{stash}->{portal} =
                      $portal->{portal};

                    $self->set_auth_routes(
                                   authorization => $portal->{authentication},
                                   url_prefix    => $url_prefix,
                                   default_index =>
                                     $portal->{authentication}->{default_index},
                                   stash  => $portal->{authentication}->{stash},
                                   portal => $portal_name
                    );
                }

                foreach my $page ( @{ $portal->{pages} } )
                {
                    my $path       = $url_prefix . $page->{path};
                    my $r          = $self->routes;
                    my $method     = $page->{method};
                    my $controller = $page->{controller};
                    my $action     = $page->{action};
                    my $route_name = $page->{route_name};
                    my $page_name = $page->{name};

                    my $stash = $page->{stash};
                    my %stash = ();
                    %stash = %{$stash} if ($stash);
                   
                    $self->stash( $route_name . 'stash' => \%stash )
                      ;    #add stash to route name for easy usage later

                    $r->$method($path)->name($route_name)->to(
                        namespace => $controller,
                        action    => $action,
                        portal    => $portal_name,
                        route_name => $route_name,
                        page        => $page_name,
                        layout    => $layout,

                        %stash,
                    );

                   

                }

            }
        }

        foreach my $route (@list)
        {
            my $method     = $route->{method};
            my $path       = $route->{path};
            my $name       = $route->{name};
            my $controller = $route->{controller};
            my $action     = $route->{action};
            my $type       = $route->{type} || 0;

            my $r = $self->routes;

            $r->$method($path)->name($name)

              ->to(
                    namespace => $controller,
                    action    => $action,
                    __TYPE__  => $type,
              );

        }

    }

  #add save all models route
  #    $r->any('//#__URLPREFIX__/__SAVEALLMODELS__/')->name('__SAVEALLMODELS__')
  #	->to( namespace =>'Zoe::ZoeController', action =>'save_all_models');

}

sub set_auth_routes
{

    my $self       = shift;
    my $r          = $self->routes;
    my %args       = @_;
    my $stash      = $args{stash} || {};
    my $url_prefix = $args{url_prefix} || '/__ADMIN__/';

    my $portal = $args{portal} || '';

    my $prefix_name = $args{url_prefix} || '';
    $prefix_name =~ s/\///gmx;

    my $auth_config = $args{authorization} || $self->get_auth_config();

    my $login_controller =
      $auth_config->{login_controller} || 'Zoe::AuthenticationController';
    my $login_show_method = $auth_config->{login_show_method} || 'show_login';
    my $login_do_method   = $auth_config->{login_do_method}   || 'do_login';

    my $logout_controller =
      $auth_config->{logout_controller} || 'Zoe::AuthenticationController';
    my $logout_do_method = $auth_config->{logout_do_method} || 'logout';

    my $login_path  = $auth_config->{login_path}  || 'login';
    my $logout_path = $auth_config->{logout_path} || 'logout';

    my $template = $auth_config->{login_template};

    $r->get( $url_prefix . $login_path )
      ->name( $prefix_name . "__SHOWLOGIN__" )->to(
        action    => "$login_show_method",
        namespace => "$login_controller",
        %$stash,
        template      => $template,
        portal        => $portal,
        url_prefix    => $url_prefix,
        default_index => $args{default_index}

      );
    $r->post( $url_prefix . $login_path )->name( $prefix_name . "__DOLOGIN__" )
      ->to(
            action    => "$login_do_method",
            namespace => "$login_controller",
            %$stash,
            template      => $template,
            portal        => $portal,
            url_prefix    => $url_prefix,
            default_index => $args{default_index}
      );
    $r->any( $url_prefix . $logout_path )
      ->name( $prefix_name . "__DOLOGOUT__" )->to(
                                           action    => "$logout_do_method",
                                           namespace => "$logout_controller",
                                           %$stash,
                                           template      => $template,
                                           portal        => $portal,
                                           url_prefix    => $url_prefix,
                                           default_index => $args{default_index}
      );
}
1;
