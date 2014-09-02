package Zoe::Runtime::Model;
use Mojo::Base 'Zoe::Runtime';

sub new
{
    my $class = shift;
    my %arg   = @_;
    my $self = {
        object              => undef, #Name of Model object
        table               => undef, #Name of Model table
        has_many            => [],    #HasMany Relationships
        many_to_many        => [],    #ManyToManyRelationships
        columns             => [],    #Column objects
        inital_values       => [],    #array of hashes, where key maps to the column name,
                                      # and the value maps to the column value
                                      
        mandatory_fields => [ 'object', 'table', 'columns'],    #mandatory fields
        
        %arg
    };
    return bless $self, $class;
}
1;
__DATA__

=head1 NAME

ZOE::Runtime::Model

=head1 Description

Stores the runtime etails for a Zoe::Runtime::Model.  
Model  details are read from the runtime.yml file or passed as key values to the Model constructer
keys and description below

        object          Name of Model object
        table           Name of Model table
        has_many        HasMany Relationships
        many_to_many    ManyToManyRelationships
        columns         olumn objects
        inital_values   array of hashes, where key maps to the column name,
                        and the value maps to the column value
                                      
        mandatory_fields => [ 'object', 'table', 'columns'],    #mandatory fields
        
=head1 YML Examples    

=head2 Simple

Define the Model details:

    objects:
      - object: Environment
        table: Environment
        columns:
         -  name: ID
            type: integer
            constraints:        #not null default for pimary keys
            primary_key: 1
         -  name: name
            type: varchar
            constraints: "not null"

For more details on Column options please see:  L<Zoe::Runtime::Column>
           
=head2 HasMany 

objects:
      - object: Namespace::Environment
        has_many:
         -  object: Namespace::Host
            key: Environment_ID
            member: Hosts
        table: Environment
        columns:
         -  name: ID
            type: integer
            constraints:
            primary_key: 1
         -  name: name
            type: varchar
            constraints: "not null"
            to_string: 1
    
      - object: Namespace::Host
        table: Host
        columns:
         -  name: ID
            type: integer
            constraints:
            primary_key: 1
         -  name: name
            type: varchar
            constraints: "not null"
            to_string: 1
         -  name: Environment_ID
            type: integer
            constraints: "not null"
            foreign_key: Namespace::Environment
            member: Environment
            
=head2 ManyToMany

      - object: Namespace::Job
        many_to_many:
         -  object: Namespace::Host
            table: JobXHost
            my_column: Job_ID
            relationship_col: Host_ID
            member: Hosts
            primary_key: ID   
    
        table: Job
        columns:
         -  name: ID
            type: integer
            constraints:
            primary_key: 1
         -  name: title
            type: varchar
            constraints:  "not null"
            to_string: 1
         -  name: run_as_user
            type: varchar
            constraints: "not null"

=head1 Author
    
dinnibartholomew@gmail.com
    

=cut

