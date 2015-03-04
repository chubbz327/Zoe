package Zoe::Runtime;
use Mojo::Base -strict;
use JSON::Any;
use Zoe::Runtime::Model;
use Zoe::Runtime::Authorization;
use Zoe::Runtime::ServerStartUp;

use Zoe::DataObject;
use parent qw( Zoe::DataObject);

sub new {

	my $class = shift;
	my $type = $class;
	my %arg   = @_;

	my $self = {
		serverstartup => undef,    #Server startup configuration
		database      => undef,    #database configuration
		models        => [],       #list of object configuration
		authorization => undef,    #authentication, authrization configuration
		routes        => [],       #Routes configuration

		mandatory_fields => [ 'serverstartup', 'database', 'models', ]
		,                          #mandatory fields

		types => {
			serverstartup => 'Zoe::Runtime::ServerStartUp',
			models        => 'Zoe::Runtime::Model',
			authorization => 'Zoe::Runtime::Authorization',
		},
		#_init_data =>, \%arg,

		%arg
	};
	my $sql = {};
	
	#set the table name
    $sql->{TABLE} = 'ZoeRuntime';

    #set the table definitions
    @{ $sql->{COLUMNS} } = qw(ID name );

    #define the primary key
    $sql->{PRIMARYKEY} = qq/ID/;

    #set the foreign kyes

    #set has many relationships
    #__HASMANY__
      #create array ref for has_many object unless it already exists
                       #object         #member             #fk_column
                        $sql->{HASMANY}->{'Zoe::Runtime::Model'} = [] unless ( ref ($sql->{HASMANY}->{'Zoe::Runtime::Model'}) eq 'ARRAY' );
                        #push member to key hash into array ref
                        push(@{$sql->{HASMANY}->{'Zoe::Runtime::Model'} }, {'models' => 'Runtime_ID' });


    #set has manytomany relationships
    my $many_description;
    #__MANYTOMANY__



   
    $self = __PACKAGE__->SUPER::new( @_, SQL => $sql );
    return bless $self;

	#$self = bless $self, $class;

	#initialize serverstartup

	#$self->initialize();
	return $self;
}

sub get_column_info {
    my $self =shift;
    my @column_info = (
        'ID', 'integer',
'name', 'timestamp',

    );
    return @column_info;
}

sub get_route {
    my $self    = shift;
    return '#__ROUTE__';
}

sub get_display_as_for {
    my $self = shift;
    my $column_name = shift;
    my %display_as = (


    );

    return $display_as{$column_name} || $column_name;
}


sub get_select_options_for {
    my $self = shift;
    my $column_name = shift;
    my %select_options = (

    );
    return $select_options{$column_name};

}


sub get_linked_create {
    my $self = shift;
    my $linked_create = {

    };
    return $linked_create;
}


sub get_searchable_columns {
    my $self = shift;
    my @searchable_columns = (
        'ID', 'name',
    );
    return @searchable_columns;
}

sub is_required_column {
    my $self = shift;
    my $column = shift;
    my %required_column = (

        'name' => 1 ,


        );
    return $required_column{$column} if ( defined($required_column{$column}) );
    return undef;
}


sub get_column_display {
    my $self = shift;
    my $column = shift;
    my %display = (



        );

    return $display{$column} if ( defined($display{$column}) );

    return undef;
}

sub to_string {
    my $self = shift;
    return $self->{
     'name'
    };

}
sub get_to_string_member {
    my $self = shift;


     return 'name';

}

sub get_upload_path {
    my $self = shift;
    return "$FindBin::Bin/../public/" . 'upload/Zoe_Runtime';
}

sub get_public_upload_path {
    my $self = shift;
    return '/upload/Zoe_Runtime/';
}

sub is_auth_object{
    my $self =  shift;
    return 0;

}

sub auth_object_info {
    my $self = shift;

    return qw( );

}

sub get_no_select {
    my $self = shift;
    return ();

}
sub get_object_name_short_hand {
    my $self = shift;
    return 'zoe_runtime';
}


sub check_valid {
	my $self       = shift;
	my @not_valids = ();

	#check mandatory fields
	foreach my $field ( @{ $self->{mandatory_fields} } ) {

		my $ref_type = ref( $self->{$field} );
		if ($ref_type) {

			if ( $ref_type eq 'ARRAY' ) {
				push( @not_valids, $field )
				  unless ( ( defined( $self->{field} ) )
					&& ( @{ $self->{$field} } ) );

			}
			elsif ( $ref_type eq 'HASH' ) {
				push( @not_valids, $field )
				  unless ( ( defined( $self->{field} ) )
					&& ( %{ $self->{$field} } ) );
			}
		}
		else {
			push( @not_valids, $field ) unless ( defined( $self->{field} ) );
		}
	}

	#check dependant fields
	foreach my $field ( keys( %{ $self->{dependant_fields} } ) ) {
		if ( defined( $self->{$field} ) ) {
			my @required = @{ $self->{dependant_fields}->{$field} };
			foreach my $required (@required) {
				unless ( defined( $self->{$required} ) ) {
					push( @not_valids, $required );
				}
			}

		}
	}

	return @not_valids;
}

1;
__DATA__

=head1 NAME

ZOE::Runtime

=head1 Description

Parent class to all  Zoe::Runtime objects 
The Zoe::Runtime consists of all application configuration data including:
    
    L<Zoe::Runtime::ServerStartup>
    L<Zoe::Runtime::Database>
    L<Zoe::Runtime::Model>
    L<Zoe::Runtime::Authorization>
    L<Zoe::Runtime::Routes>
    
As well as the configuration for any other external modules added




=head1 Methods

Method description below:

=over 4

=item check_valid

Returns a list of non valid fields for the Runtime object; empty array if valid

=back 

=head1 Author
    
dinnibartholomew@gmail.com
    

=cut
