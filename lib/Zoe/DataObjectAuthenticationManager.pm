package Zoe::DataObjectAuthenticationManager;
use Mojo::Base -strict;
use YAML::Tiny;
use Net::LDAP;
use Log::Message::Simple qw[msg error debug
  carp croak cluck confess];
use List::MoreUtils qw{any};
use Scalar::Util qw(reftype);
use Digest::SHA1 qw(sha1_hex);
use Path::Class;

use Data::Dumper;
my $auth_config = 0;
my $is_verbose  = 1;
use constant EMPTY_STRING => '';

BEGIN { unshift @INC, "$FindBin::Bin/../lib" }
use vars
  qw($auth_object_lib $auth_object $role_column $salt_member $password_member $user_name_member $role_object);

sub new {
    my $class = shift;
    unless ($auth_config){
    $auth_config = shift;
    }

    my %data_object_config = %{ $auth_config->{config}->{data_object} };
    $auth_object        = $data_object_config{auth_object};
   $auth_object_lib    = $data_object_config{auth_object_lib};
    
    my $lib_dir = dir("$FindBin::Bin", '..', 'lib', split(/\//, $auth_object_lib) );
    unshift @INC, "$lib_dir";
    
   eval  "require $auth_object";
    
    $role_column     = $data_object_config{role_column};
    $salt_member     = $data_object_config{salt_member};
    $password_member = $data_object_config{password_member};
    $user_name_member   = $data_object_config{user_name_member};
    $role_object        = $data_object_config{role_object};
    
    eval "require $role_object";
    unless ( $auth_object && $role_column && $salt_member && $password_member &&  $user_name_member) {
        croak "auth_object role_column password_member salt_member user_name_member are required for data_object authentication";
    }
    my $self = bless {@_}, $class;
    return $self;
}


sub do_check {
    my $self                 = shift;
    my $controller           = shift;
    my $login_user_param     = $auth_config->{login_user_param};
    my $login_password_param = $auth_config->{login_password_param};

    debug(
        __PACKAGE__
          . ": searching request parameters for $login_user_param $login_password_param",
        $is_verbose
    );
    my $user_name   = $controller->param($login_user_param);
    my $password    = $controller->param($login_password_param);
    
    eval  "require $auth_object";
    
    my @all         = $auth_object->new()->load_by( where=>{$user_name_member => $user_name} );
    my $user        = $all[0];
    
 

    return 0 unless (($user) && ($user->{$user_name_member} ) ) ;
    debug( __PACKAGE__ . ": User entry Found" . $user->{$user_name_member}, 1 );

   
 #check supplied password
    my $salt  = $user->{$salt_member};
    my $hash  = sha1_hex($salt . $password);
    
    
    print "HASH $hash IS SHOULD BE " .  $user->{$password_member} . "\n";
    return 0 unless($hash eq $user->{$password_member});


    #autheticated
    #add user session key to session
    debug(
        __PACKAGE__
          . ":Adding user_session_key "
          . $auth_config->{user_session_key}
          . " with value of " . $user_name,
        $is_verbose
    );

    $controller->session( $auth_config->{user_session_key}, => $user_name );

    #set role session keys
    my $role = $role_object->find($user->{$role_column}); 

    my $role_string = $role->to_string();
    
    debug(
        __PACKAGE__
          . ":Adding role_session_key"
          . $auth_config->{role_session_key}
          . "with value of $role_string",
        $is_verbose
    );
    $controller->session( $auth_config->{role_session_key}, => $role_string );
    return 1;    

}



1;
