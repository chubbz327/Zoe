package Zoe::Runtime::ManyToMany;
use Mojo::Base 'Zoe::Runtime';

sub new
{
    my $class = shift;
    my %arg   = @_;
    my $self = {
        object              => undef, #Name of ManyToMany object
        table               => undef, #Name of ManyToMany join table
        relationship_col    => undef, #foreign key in ManyToMany join table
        my_column           => undef, #Objects' column in ManyToMany join table
        member              => undef, #Object member variable which contains many to many objects
        primary_key         => undef, #primary key column of ManyToMany join table
        
        mandatory_fields => [ 'object', 'relationship_col', 'my_column', 
                               'table', 'primary_key', 'member' ],    #mandatory fields
         
        %arg
    };
    return bless $self, $class;
}
1;
__DATA__

=head1 NAME

ZOE::Runtime::ManyToMany

=head1 Description

Stores the runtime many to many   details for a L<Zoe::Runtime::Model> .  
Many to many details are read from the runtime.yml file or passed as key values to the Has constructer
keys and description below

        object              Name of ManyToMany object
        table               Name of ManyToMany join table
        relationship_col    foreign key in ManyToMany join table
        my_column           Objects' column in ManyToMany join table
        member              Object member variable which contains many to many objects
        primary_key         primary key column of ManyToMany join table
        
        mandatory_fields => [ 'object', 'relationship_col', 'my_column', 
                               'table', 'primary_key', 'member' ],    #mandatory fields


=head1 Author
    
dinnibartholomew@gmail.com
    

=cut

