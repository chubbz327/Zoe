package Zoe::AuthenticationController;
use Zoe::LDAPAuthenticationManager;
use Zoe::DataObjectAuthenticationManager;

 
use Mojo::Base 'Mojolicious::Controller';
use Log::Message::Simple qw[msg error debug
  carp croak cluck confess];
use Data::Dumper;
 
BEGIN { unshift @INC, "$FindBin::Bin/../" }

my %auth_method = ();
$auth_method{ldap} = "Zoe::LDAPAuthenticationManager";
$auth_method{data_object} = "Zoe::DataObjectAuthenticationManager";
my $is_verbose = 1;

sub logout {
    my $self = shift;
    my $url = $self->url_for('__SHOWLOGIN__')->query( message=>'You have been logged out');
   
    $self->session(expires => 1);
    $self->redirect_to($url);
    return;
    
}

sub show_login {
    my $self = shift;
    my $auth_config = $self->get_auth_config();
    my $default_index = $auth_config->{default_index};
    my $message = ($self->param('message') ||  "Please enter login credentials");
    my $url = $self->url_for('__SHOWLOGIN__');
    my $requested_url = ($self->param('requested_url') || $default_index);
    
    print "REQUESTED_URL $requested_url\n\n";
    my $template = $auth_config->{login_template};
    $self->render(      message=> $message, 
                        url => $url,
                        template => "$template",
                        requested_url => $requested_url
                        );
}

sub do_login {
    my $self = shift;
    my $auth_config = $self->get_auth_config();
    my $default_index = $auth_config->{default_index};
    
    my $url = $self->url_for('__SHOWLOGIN__');
    my $auth_success = 0;
    #print Dumper $auth_config->{methods};
    my %methods = %{$auth_config->{methods}};
    foreach my $method ( keys( %methods ) ) {
        my $auth_handler = $methods{$method};
        
        if ( $auth_handler ne '__DEFAULT__') {
            eval "use " . $auth_handler;
           $auth_success = (($auth_handler->new($auth_config))->do_check($self)) unless ($auth_success);         
        }else {
            #auth_handler set to default
            croak "Authentication method $method does not exist" unless defined($auth_method{$method});
            
            $auth_handler = $auth_method{$method};
            eval "use " . $auth_handler;
            $auth_success = (($auth_handler->new($auth_config))->do_check($self)) unless ($auth_success); 
        }  
        debug(__PACKAGE__ . ":auth_handler $auth_handler "  , $is_verbose);     
    }
    if ($auth_success) {
        
        my $redirect_to = ($self->param('requested_url') || $default_index || '/');
        debug(__PACKAGE__ . "Login Success, redirect_to  " .  $redirect_to  , $is_verbose);
        $self->redirect_to($redirect_to);
    }else {
        my $template = $auth_config->{login_template};
        my $login_user_param = $auth_config->{login_user_param};
        my $login_user_param_value = $self->param($login_user_param);
         my $requested_url = ($self->param('requested_url') || $default_index);
        debug(__PACKAGE__ . "Login failed, rendering template " .   $template , $is_verbose);
        $self->render(  message=>"Check verify the credentials provided", 
                        template => $template, 
                        $login_user_param => $login_user_param_value, url => $url, requested_url => $requested_url);
    
    }
    return;
     
}

1;

