package Zoe::Runtime::ServerStartUp;
use Mojo::Base 'Zoe::Runtime';
use Zoe::Runtime::EnvironmentVariable;

sub new
{
    my $class = shift;
    my %arg   = @_;
    my $self = {
        application_name        => undef, #Name of Application
        location                => undef, #path to application home directory        
        environment_variables   => [],    #foreign key in ServerStartUp join table
               
        mandatory_fields => [ 'application_name', 'location'],    #mandatory fields
        types			=> 	{
        						environment_variables => 'Zoe::Runtime::EnvironmentVariable',        	
        					},
     
        %arg
    };
    
    #initialize children
    $self = bless $self, $class;
    #initialize serverstartup
    
    $self->initialize();
    return $self; 
}



sub get_form_schema {
	my $self = shift;
	return {
				type => 'object',
	        	properties =>{
		        	application_name => {
		        		type => 'string',
		        		title => 'Application name',
		        		required => 'true',
		        	},
		        	location => {
		        		type => 'string',
		        		title => 'Application location',
		        		required => 'true',
		        	},
		        	environment_variables => {
		        		type => 'array',
		        		title => 'Environment Variables',
		        		required => 'false',
		        		items =>Zoe::Runtime::EnvironmentVariable->new()->get_form_schema,
		        	}
		        		
		            	
	        }
		
	};
}


1;
__DATA__

=head1 NAME

ZOE::Runtime::ServerStartUp

=head1 Description

Stores the runtime startup information for the Application Startup controller;
application subclass of L<Zoe::Controller> .  
ServerStartUp parameters are stored in the runtime.yml file or passed as key values to the ServerStartUp constructer
keys and description below

        application_name        Name of Application
        location                path to application home directory        
        environment_variables   array of environment valirable hashes
               
        mandatory_fields => [ 'application_name', 'location'],    #mandatory fields

=head1 YML Examples    
     
         startup:   
           application_name: AppliccationName
           ocation: /var/applications/appplication-name
           environment_variables:
              MOJO_MODE: development
              MOJO_LISTEN: http://*:8765

=head1 Author
    
dinnibartholomew@gmail.com
    
=cut

