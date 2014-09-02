package Zoe::Runtime::Authorization;
use Mojo::Base 'Zoe::Runtime';

sub new
{
    my $class = shift;
    my %arg   = @_;
    my $self  = {
        login_path           => undef,  #path to login i.e /login
        login_controller     => undef,  #login controller to use; Default is Zoe::AuthenticationController
        login_show_method    => undef,  #login method of the login_controller
        login_do_method      => undef,  #Where login form submits
        login_template       => undef,  #login template location relative to template dir
        login_user_param     => undef,  #request parameter that determines the user name
        login_password_param => undef,  #request parameter that determines the password
        default_index        => undef,  #default index, mapping of roles to index shown post login
        logout_path          => undef,  #path to login i.e /login
        logout_controller    => undef,  #logout controller to use; Default is Zoe::AuthenticationController
        logout_do_method     => undef,  #logout method of the logout_controller
        user_session_key     => undef,  #session key where user login_user_param is stored
        role_session_key     => undef,  #session key where user roles ares stored; stored as yaml
        roles                => [],     #list of application roles
        methods              => {},     #authentication methods used, (ldap| data_object)
        config               => [],     #authorization configuration---this includes 
                                        #   route permissions  database connection info, ldap server info
                                        #   ldap group to role mapping 
                                        
        mandatory_fields => \qw(    login_path login_controller login_show_method 
                                    login_do_method login_template login_user_param
                                    login_password_param default_index logout_path
                                    logout_controller logout_do_method user_session_key
                                    role_session_key roles methods config
                                    ),
                                       #mandatory fields
        
        %arg
    };
    return bless $self, $class;
}
1;
__DATA__

=head1 NAME

ZOE::Runtime::Authorization

=head1 Description

Stores the runtime authorization information 
Authorization parameters are stored in the runtime.yml file or passed as key values to the Authorization constructer
keys and description below

        login_path              path to login i.e /login
        login_controller        login controller to use; Default is Zoe::AuthenticationController
        login_show_method       login method of the login_controller
        login_do_method         Where login form submits
        login_template          login template location relative to template dir
        login_user_param        request parameter that determines the user name
        login_password_param    request parameter that determines the password
        default_index           default index, mapping of roles to index shown post login
        logout_path             path to login i.e /login
        logout_controller       logout controller to use; Default is Zoe::AuthenticationController
        logout_do_method        logout method of the logout_controller
        user_session_key        session key where user login_user_param is stored
        role_session_key        session key where user roles ares stored; stored as yaml
        roles                   list of application roles
        methods                 authentication methods used, (ldap| data_object)
        config                  authorization configuration---this includes 
                                route permissions  database connection info, ldap server info
                                ldap group to role mapping 

=head1 YML Examples   

=head2 data_object

Used for database authentication

        authorization:
          login_path: /login
          login_controller: Zoe::AuthenticationController
          login_show_method: show_login
          login_do_method: do_login
          login_template: signin
          login_user_param: user
          login_password_param: password
          default_index: /
        
          logout_path: /logout
          logout_controller: Zoe::AuthenticationController
          logout_do_method: logout
        
        
        
          user_session_key: user_id
          role_session_key: role
          roles:
            -  name: admin
            -  name: user
          methods:
            data_object: __DEFAULT__
        
          config:
            routes:
              -  path: /admin.*
                 method: match_role
                 http_method: any
                 match_roles:
                   -  name: admin
              -  path: .*
                 method: match_role
                 http_method: any
                 match_roles:
                   -  name: *
        
            data_object:
              auth_object: User
              role_column: Role_ID
              salt_member: password_salt
              password_member: password_hash
              user_name_member: login
              role_object: Role
              admin_role: admin
 
=head2 ldap
     
        authorization:
          login_path: /login
          login_controller: Zoe::AuthenticationController
          login_show_method: show_login
          login_do_method: do_login
          login_template: signin
          login_user_param: user
          login_password_param: password
          default_index: /
        
          logout_path: /logout
          logout_controller: Zoe::AuthenticationController
          logout_do_method: logout
        
        
        
          user_session_key: user_id
          role_session_key: role
          roles:
            -  name: admin
            -  name: web_user
          methods:
            ldap: __DEFAULT__
        
          config:
            routes:
              -  path: .*
                 method: match_role
                 http_method: any
                 match_roles:
                   -  name: admin
        
            ldap:
              server: ldapserver.myorg.com
              base_dn: "dc=myorg,dc=com"
              search_password: password_goes_here
              search_user: 'CN=Searcher,OU=Accounts,dc=myorg,dc=com'
              search_filter: "(sAMAccountName=__USERNAME__)"
              group_dn: 'memberOf'
              user_dn: asn,objectName
              groups_for_role:
                -  role_name: admin
                   member_of:
                     -  'CN=IT,OU=Ninjas,dc=myorg,dc=com'
                     -  'CN=Operations,OU=Operations,OU=Ninjas,dc=myorg,dc=com' 
                -  role_name: web_user
                   member_of:
                     -  *

=head1 Author
    
dinnibartholomew@gmail.com
    
=cut

