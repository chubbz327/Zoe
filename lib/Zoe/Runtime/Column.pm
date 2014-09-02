package Zoe::Runtime::Column;
use Mojo::Base 'Zoe::Runtime';


sub new {

    
    my $class = shift; 
      my %arg  = @_;
    my $self = {
        name            => undef,   #database column name mandatory
        type            => undef,   #database column type mandatory
        contraints      => undef,   #database column constraints
        primary_key     => undef,   #is primary key? 0 or 1
        to_string       => undef,   #return column value when to_string is called
        foreign_key     => undef,   #foreign key object type
        member          => undef,   #foreign key member name that maps to column name - mandatory if foreign_key specified
        input_type      => undef,   #html imput type - defaults to text
        select_options  => {},      #select options if input type is select- mandatory when input_type is select
        display         => undef,   #string evaluated and returned when displayed via html defaults to the column value
                                    #   for example: display: |return "<img width='140' height='140' class='img-rounded' src='" . $object->get_media() . "'/>";
                                    #   where the column name is image,
       mandatory_fields => ['name', 'type'],
       dependant_fields =>{'foreign_key' =>['member']},

        %arg
    };

    return bless $self, $class;
}

1;
__DATA__

=head1 NAME

ZOE::Runtime::Column

=head1 Description

Stores the runtime column details for a Zoe::Runtime::Object.  
Column details are read from the runtime.yml file or passed as key values to the Column constructer
keys and description below

        name            database column name mandatory
        type            database column type mandatory
        contraints      database column constraints if set to not null,
                        will be mandatory in html form
        primary_key     is primary key? 0 or 1
        to_string       return column value when to_string is called
        foreign_key     foreign key object class name(type)
        member          foreign key member name that maps to column name 
                            - mandatory if foreign_key specified
        input_type      html imput type - defaults to text
        select_options  select options if input type is select
                            - mandatory when input_type is select
        display         string evaluated and returned when displayed 
                        via html defaults to the column value
                        for example: 

            display: |
                return "<img width='140' height='140' class='img-rounded' src='" . $object->get_media() . "'/>";
                        
                        where the column name is image,
        
        mandatory_fields => ['name', 'type'], #list of mandatory fields
     
        #field that is mandatory if another field is populated; i.e if foreign_key is set, member is mandatory        
        dependant_fields =>{'foreign_key' =>['member']}, 


=head1 Author
    
dinnibartholomew@gmail.com
    

=cut