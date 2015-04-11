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
     my $show_login ='__SHOWLOGIN__' ;
    
    my $url;
    
    if ($self->param('requested_url') || $self->stash('default_index') ) {
        $url = $self->param('requested_url') || $self->stash('default_index');
        
        $self->session(expires => 1);
        $self->redirect_to($url);
        
    }else {
        my $portal = $self->get_portal() || {};
         my $name_prefix = $portal->{url_prefix} || '';
 $name_prefix =~ s/\///gmx;
    $show_login  = $name_prefix . '__SHOWLOGIN__';
        $url = $self->url_for($show_login)->query('message' => 'You have logged out')
    }
$self->session(expires => 1);
    
    
    return $self->redirect_to($url);
    
}

sub show_login {
    my $self = shift;
    my $auth_config = $self->get_auth_config();
    my $default_index = $auth_config->{default_index};
    my $message = ($self->param('message') ||  "Please enter login credentials");
    my $url = $self->url_for();
   
    my $requested_url = ( $self->param('requested_url') || $self->stash('default_index') || $self->stash('url_prefix') || $default_index );
    
    my $layout = ($self->stash('layout') || '');
    my $template = $self->stash('template') || $auth_config->{login_template};
    $self->render(      message=> $message, 
                        url => $url,
                        template => "$template",
                        requested_url => $requested_url,
                        layout => $layout, 
                        );
}

sub do_login {
    my $self = shift;
    my $auth_config = $self->get_auth_config();
    my $default_index = $auth_config->{default_index};
    my @post_auth_handlers =  ();
    
    @post_auth_handlers  = @{ $auth_config->{post_auth_handler} }  
        if ($auth_config->{post_auth_handler});
    my $url = $self->url_for('__SHOWLOGIN__');
    my $auth_success = 0;
    #print Dumper $auth_config->{methods};
    my %methods = %{$auth_config->{methods}};
    foreach my $method ( keys( %methods ) ) {
        my $auth_handler = $methods{$method};
        
        if ( $auth_handler ne '__DEFAULT__') {
            eval "use " . $auth_handler;
           # print "FINd BIN $FindBin::Bin/../\n\n";
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
        
        foreach my $post_auth_handler (@post_auth_handlers) {
            debug(__PACKAGE__ . "POST AUTH: $post_auth_handler");
            eval "require $post_auth_handler";
            die $@ if $@;
            $post_auth_handler->new($auth_config)->handle($self); 
            
            
        }
        
       
        if ($self->req->is_xhr() ) {
             debug(__PACKAGE__ . "Login Success IS_XHR 1", $is_verbose);
            return $self->render( json => { result => 1 } );
            
        }
         my $redirect_to = ($self->param('requested_url') || $default_index || '/');
        debug(__PACKAGE__ . "Login Success, redirect_to  " .  $redirect_to  , $is_verbose);
        
        $self->redirect_to($redirect_to);
    }else {
        
        debug(__PACKAGE__ . "Login Success IS_XHR 0 ", $is_verbose);
        
        if ($self->req->is_xhr() ) {
            return $self->render( json => { result => 0} );
            
        }
      
        my $template = $self->stash('template') || $auth_config->{login_template};
        my $login_user_param = $auth_config->{login_user_param};
        my $login_user_param_value = $self->param($login_user_param);
         my $requested_url = ($self->stash('url_prefix') || $self->param('requested_url') || $default_index);
        debug(__PACKAGE__ . "Login failed, rendering template " .   $template , $is_verbose);
        
        my $auth_page = $self->param('auth_page');
        
        
        $self->redirect_to($auth_page) if ($auth_page);
        
        $self->render(  message=>"Check verify the credentials provided", 
                        template => $template, 
                        $login_user_param => $login_user_param_value, url => $url, requested_url => $requested_url);
    
    }
    return;
     
}

1;

