package Zoe::LDAPAuthenticationManager;
use Mojo::Base -strict;
use YAML::Tiny;
use Net::LDAP;
use Log::Message::Simple qw[msg error debug
  carp croak cluck confess];
use List::MoreUtils qw{any};
use Scalar::Util qw(reftype);

use Data::Dumper;
my $auth_config = 0;
my $is_verbose  = 1;
use constant EMPTY_STRING => '';
use vars
  qw($base_dn $ldap_server $search_user $search_password $search_filter $user_dn  $group_dn);

sub new {
    my $class = shift;
    unless ($auth_config){
    $auth_config = shift;
    }

    my %ldap_config = %{ $auth_config->{config}->{ldap} };
    $base_dn         = $ldap_config{base_dn};
    $ldap_server     = $ldap_config{server};
    $search_user     = $ldap_config{search_user};
    $search_password = $ldap_config{search_password};
    $search_filter   = $ldap_config{search_filter};
    $user_dn         = $ldap_config{user_dn};
    $group_dn        = $ldap_config{group_dn};
    my $self = bless {@_}, $class;

    return $self;

}

sub _get_user_cn {
    my $self      = shift;
    my $entry     = shift;
    my $ref       = $entry;
    my @hash_keys = split( /,/, $user_dn );
    my $cn        = '';

    debug( __PACKAGE__ . ": Getting username value via $user_dn", $is_verbose );

    for ( my $i = 0 ; $i < scalar(@hash_keys) ; $i++ ) {
        print "\n$i I value\n";
        my $key       = $hash_keys[$i];
        my $maybe_ref = $ref->{$key};
        if ( ref($maybe_ref) eq 'HASH' ) {
            $ref = $maybe_ref;
            print "ref is a HASH \n";
        }
        else {
            $cn = $maybe_ref;
        }

    }

#debug(__PACKAGE__ . ": User_cn string $user_dn found user " . Dumper $cn, $is_verbose);
    debug( __PACKAGE__ . ": User_cn string $user_dn found user ]",
        $is_verbose );
    return $cn;
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
    my $user     = $controller->param($login_user_param);
    my $password = $controller->param($login_password_param);

    my $entry = $self->_get_user_entry( user => $user );

    debug( __PACKAGE__ . ": User entry Found" . $entry, 1 );

    return 0 unless ($entry);    #user_name not found
    debug( __PACKAGE__ . ": Getting user cn for " . $entry, 1 );

    #get the entry cn name
    my $user_cn = $self->_get_user_cn($entry);

    #check supplied password
    my $ldap = Net::LDAP->new($ldap_server)
      or croak "$!";
    my $msg = $ldap->bind( $user_cn, password => $password );

    debug(
        __PACKAGE__ . ":Attempting to bind $user_cn with specified passoword ",
        $is_verbose
    );

    #failed login; a result code other than 0 idicates a
    #failure
    return 0 if ( $msg->{resultCode} );

    #autheticated
    #add user session key to session
    debug(
        __PACKAGE__
          . ":Adding user_session_key "
          . $auth_config->{user_session_key}
          . " with value of $user",
        $is_verbose
    );

    $controller->session( $auth_config->{user_session_key}, => $user );

    #set role session keys

    my $role_string;
    my @groups_for_role =
      @{ $auth_config->{config}->{ldap}->{groups_for_role} };
    my @user_groups = $entry->get_value($group_dn);
    foreach my $group_for_role (@groups_for_role) {

        my $role_name = $group_for_role->{role_name};
        my @member_of = @{ $group_for_role->{member_of} };
        if ( any { $_ =~ /\*/ } @member_of ) {
            debug( __PACKAGE__ . ": added role $role_name matches * ",
                $is_verbose );
            $role_string .= "$role_name,";
            next;
        }
        foreach my $group_name (@user_groups) {
            foreach my $match_group (@member_of) {
                if ( $match_group eq $group_name ) {
                    debug(
                        __PACKAGE__
                          . ": added role $role_name matches $group_name ",
                        $is_verbose
                    );
                    $role_string .= "$role_name,";
                    next;
                }
            }
        }

    }

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

sub _get_user_entry {
    my $self = shift;
    my %args = @_;
    my $ldap = $self->_get_ldap();
    my ( $user, $password );

    $user = $args{user};
    my $filter = $search_filter;

    $filter =~ s/__USERNAME__/$user/g;

    debug( __PACKAGE__ . ":Searching via filter $filter", $is_verbose );

    #autheticated now find user
    my $result = $ldap->search( base => $base_dn, filter => $filter );

    #print Dumper $result;

    #Check if user is found else return 0
    unless ( $result->{matchedDN} =~ /^EMPTY_STRING$/ ) {
        debug(
            __PACKAGE__ . ":Searching success for filter $filter base $base_dn",
            $is_verbose
        );
        return $result->entry(0);
    }
    else {
        debug(
            __PACKAGE__
              . ":Searching resulted in 0  for filter $filter base $base_dn\n"
              . Dumper $result ,
            $is_verbose
        );
        return 0;
    }
}

sub _get_ldap {
    my $self = shift;

    my $ldap = Net::LDAP->new($ldap_server) or croak "$@";
    print "$search_user, $search_password \n";

    my $msg = $ldap->bind( $search_user, password => $search_password );

    debug( __PACKAGE__ . ":get ldap " . Dumper $msg , $is_verbose );

    #if the search_user cannot be authenticated die
    if ( $msg->{resultCode} ) {    #result code of 0 is success
                                   #search_user password failed
        croak
"bad password: $search_user could not be authenticated to $ldap_server $search_password";
    }
    return $ldap;
}

1;
