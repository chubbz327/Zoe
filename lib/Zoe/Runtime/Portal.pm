package Zoe::Runtime::Portal;
use Mojo::Base 'Zoe::Runtime';
use Zoe::Runtime::EnvironmentVariable;

sub new
{
    my $class = shift;
    my %arg   = @_;
    my $self = {
        name        => undef,    #Name of portal
        url_prefix  => undef,    #url prefix
        pages       => {},       #pages within portal
        layout      => undef,    #portal layout
        role_access => [],       #list of roles that can access portal

        mandatory_fields => [ 'name', 'url_prefix', 'layout' ]
        ,                        #mandatory fields
        types => {
                   pages => 'Zoe::Runtime::Page',
        },

        %arg
    };

    #initialize children
    $self = bless $self, $class;
    Portal serverstartup

      $self->initialize();
    return $self;
}

1;
__DATA__

=head1 NAME

ZOE::Runtime::Portal

=head1 Description

Stores configuration information for each protal;  Configuration parameters are:
Portal parameters are stored in the runtime.yml file or passed as key values to the Portal constructer
keys and description below

        name        => undef,    #Name of portal
        url_prefix  => undef,    #url prefix
        pages       => [],       #pages within portal
        layout      => undef,    #portal layout
        role_access => [],       #list of roles that can access portal
        layout_menu =>[],        #list of hashes that contain the names for the menu
                                 # links in layout and corresponding pages they map to

        mandatory_fields => [ 'name', 'url_prefix', 'layout' ]
        

=head1 YML Examples    
     
         portals:
           - name: frontend   
             url_prefix: __FRONTEND__/
             layout:    top_menu
             role_access:
                - anonymous
                - admin
              pages:
              #There are two ways to use page
              # forwarding:
              #     pass page parameters to controller
              #     all parameters are included in rouite as  stash 
                - name: home  
                  route_name: __home_page__
                  controller: Zoe::ZoeActionController
                  action_name: show_all
                  path: home_page/
                  stash: 
                    __TYPE__: MyApp::Products
                    template: item_list
                    where_clause: 
                      featured: 1
                  
 

=head1 Author
    
dinnibartholomew@gmail.com
    
=cut

