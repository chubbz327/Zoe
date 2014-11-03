package Zoe::Runtime::HasMany;
use Mojo::Base 'Zoe::Runtime';

sub new
{
    my $class = shift;
    my %arg   = @_;
    my $self = {
        object => undef,    #Name of HasMany object
        key    => undef,    #foreign key in HasMany objects table
        member => undef,    #Object member variable which contains has many objects
                
        linked_create		=> undef, #boolean; show child object create on create page
        no_select			=> undef, #do not show in create			
        
        mandatory_fields => [ 'object', 'key', 'member' ], #mandatory fields
         
        %arg
    };
    return bless $self, $class;
}

1;
__DATA__

=head1 NAME

ZOE::Runtime::Column

=head1 Description

Stores the runtime has many  details for a Zoe::Runtime::Object.  
Has many details are read from the runtime.yml file or passed as key values to the Has constructer
keys and description below

        object      Name of HasMany object
        key         foreign key in HasMany objects table
        member      Object member variable which contains has many objects
        
        linked_create		=> undef, #boolean; show child object create on create page
        no_select			=> undef, #do not show in create			
        
        mandatory_fields => [ 'object', 'key', 'member' ], #mandatory fields


=head1 Author
    
dinnibartholomew@gmail.com
    

=cut

