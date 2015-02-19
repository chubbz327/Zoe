package Zoe::Runtime;
use Mojo::Base -strict;
use JSON::Any;
use Zoe::Runtime::Model;
use Zoe::Runtime::Authorization;
use Zoe::Runtime::ServerStartUp;

sub new {

	my $class = shift;
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
		_init_data =>,
		\%arg,

		%arg
	};

	$self = bless $self, $class;

	#initialize serverstartup

	$self->initialize();
	return $self;
}

sub get_JSON {
	my $self = shift;
	return JSON::Any->new( allow_blessed => 1 )
	  ->objToJson( $self->{_init_data}->{serverstartup} );

}

sub get_form_schema {
	my $self = shift;
#	return {
#		schema => {
#			type       => 'object',
#			title      => 'Run Time',
#			properties => {
#				server_startup =>
#				  Zoe::Runtime::ServerStartUp->new()->get_form_schema(),
#			}
#		}
#	};
#	return JSON::Any->new()->objToJson({
#		
#			properties => {
#				serverstartup =>
#				  Zoe::Runtime::ServerStartUp->new()->get_form_schema()
#			}
#		
#	});


return JSON::Any->new()->objToJson(
		
		
				  Zoe::Runtime::ServerStartUp->new()->get_form_schema()
			);
}

sub initialize {
	my $self = shift;

	#instantiate child objects with values stored in self
	#then assign back to $self
	foreach my $key ( keys( %{ $self->{types} } ) ) {
		my $list_ref = [];
		my $obj_type = $self->{types}->{$key};
		if ( ref( $self->{$key} ) eq 'ARRAY' ) {

			#for each object data create a new object and add to array ref
			foreach my $obj_data ( @{ $self->{$key} } ) {
				push( @{$list_ref}, $obj_type->new( %{$obj_data} ) );
			}

			#assign array ref back to self
			$self->{$key} = $list_ref;

		}
		else {

			#top level object
			my $obj_data = $self->{$key};

			$self->{$key} = $obj_type->new( %{$obj_data} ) if ($obj_data);
			
		}

	}

}

sub get_json_schema {
	my $self = shift;
	my @keys = $self->get_keys();

	foreach my $key (@keys) {
		unless ( ref( $self->{key} ) ) {

			#scalar value

			next;
		}
	}

}

sub get_keys {
	my $self = shift;

	my @keys = keys( %{$self} );
	my @return;
	foreach my $key (@keys) {
		push( @return, $key )
		  unless ( $key =~ /mandatory_fields|dependant_fields|_schema/i );
	}

	return \@return;

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
