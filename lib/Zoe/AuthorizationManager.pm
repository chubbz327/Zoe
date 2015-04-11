package Zoe::AuthorizationManager;
use Mojo::Base -strict;
use Data::Dumper;
#use Data::Serializer;
use YAML::XS;
my $auth_config = 0;
my $is_verbose  = 1;

use Log::Message::Simple qw[msg error debug
  carp croak cluck confess];

sub new
{
    my $class = shift;

    unless ($auth_config)
    {
        $auth_config = shift;

    } else
    {
        shift;
    }
    my $self = bless {@_}, $class;

    return $self;
}

sub do_check
{
    my $self                = shift;
    my $controller          = shift;
    my $url_prefix          = shift || '/__ADMIN__/';
    my $request_http_method = $controller->req->method;

    my $user_yaml =
      ( $controller->session( $auth_config->{user_session_key} ) || 0 );
    #return 0 unless( $user );
    
    my $user = 0;
    $user = YAML::XS::Load($user_yaml) || {};
    
      
    my $roles_dump =  ( $controller->session( $auth_config->{role_session_key} ) || 0 );
   # my $dumper = Data::Serializer->new();
    my $roles = YAML::XS::Load($roles_dump) || {}; #unserialize roles array
    
    #print "ATUH " . Dumper $roles;
    #return 0 unless( $roles );
    if (defined($roles) ) {
    unless ( ref $roles eq 'ARRAY' )
    {
        $roles = [ $roles, ];
    }
    }

    my $requested_url = $controller->req->url->path;
    my $login_url     =  ($auth_config->{login_path} || 'login');
    my $logout_url    =  $url_prefix . ($auth_config->{logout_path} || 'login');
    return 1 if ( $requested_url =~  /$login_url/ );
    return 1 if ( $requested_url =~ /$logout_url/ );

    #return 1 if ($requested_url eq "/");
    return 1 if ( $requested_url =~ /assets/ );
    return 1 if ( $requested_url =~ /mojo/ );
    return 1 if ( $requested_url =~ /__NOT/ );

    my @routes  = @{ $auth_config->{config}->{routes} };
    my $success = 0;
    foreach my $role ( @{$roles} )
    {
	#debug (Dumper $role, 1);
        for ( my $i = 0 ; $i < scalar(@routes) ; $i++ )
        {
            my $route  = $routes[$i];
            my $method = '_' . $route->{method};
            
            $success =
              $self->$method( $route, $user, $role->{name}, $requested_url,
                              $request_http_method );
            debug(
                   __PACKAGE__
                     . "CHECK RESULT: requested url: $requested_url path"
                     . $route->{path}
                     . "and method $request_http_method - "
                     . " role : $role->{name} --result $success",
                   $is_verbose
            );
           
            if ( $success eq 'pass' )
            {

                return 1;
            } elsif ( $success eq 'fail' )
            {
                return 0;
            }
        }
    }
    
   

}

sub _match_role
{
    my $self                = shift;
    my $route               = shift;
    my $user                = shift;
    my $role_string         = shift || '__anonymouns__';
    my $requested_url       = shift;
    my $request_http_method = shift;

    my @match_roles = @{ $route->{match_roles} };
    my $route_path  = $route->{path};
    my $http_method = $route->{http_method};

    $http_method =~ s/\s+//g;
    $request_http_method =~ s/\s+//g;

    $http_method         = lc($http_method);
    $request_http_method = lc($request_http_method);

    #print "$request_http_method  $http_method\n\n";
    my $return =
      '';    # return can have 3 posible values pass , not_matched, failed

    $http_method = $request_http_method if ( $http_method =~ /any/i );

    if ( $requested_url =~ /$route_path/igmx )
    {
       # print "HEREdinni\n";
        debug( __PACKAGE__ . ": $route_path matches $requested_url " );
        foreach my $needed_role (@match_roles)
        {    #for this path *, all roles are accepted
            #print "$role_string NEEDED ROLE " . $needed_role->{name};
            if (    ( $needed_role->{name} =~ /\*/ )
                 && ( $request_http_method eq $http_method ) )
            {
                debug(
                    __PACKAGE__
                      . ": requested url: $requested_url matches route path $route_path and method $http_method- allowing all roles",
                    $is_verbose
                );
                return 'pass';

            }

            elsif (    ( $role_string =~ /$needed_role->{name}/igmx )
                    && ( $request_http_method eq $http_method ) )
            {

                debug(
                    __PACKAGE__
                      . ": requested url: $requested_url matches route path $route_path  and method $http_method - needed role: "
                      . $needed_role->{name}
                      . " matches $role_string",
                    $is_verbose
                );
                return 'pass';
            } else
            {
                debug(
                    __PACKAGE__
                      . ": requested url: $requested_url matches route path $route_path  and method $http_method - needed role: "
                      . $needed_role->{name}
                      . " does not matche $role_string",
                    $is_verbose
                );
                
                return 'fail';
            }
        }
    }

    debug(
        __PACKAGE__
          . ": requested url: $requested_url does not matches route path $route_path and method $http_method ",
        $is_verbose
    );
    return 'not_matched';
}

1;
