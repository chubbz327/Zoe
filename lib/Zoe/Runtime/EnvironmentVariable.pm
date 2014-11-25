package Zoe::Runtime::EnvironmentVariable;
use Mojo::Base 'Zoe::Runtime';

sub new
{
    my $class = shift;
    my %arg   = @_;
    my $self = {
        key        => undef, #Variable name
        value       => undef, #variable value   
             
               
        mandatory_fields => [ 'name', 'value'],    #mandatory fields
        
        
     
        %arg
    };
    return bless $self, $class;
}


sub get_form_schema {
	my $self = shift;
		return {
				type => 'object',
	        	properties =>{
		        	key => {
		        		type => 'string',
		        		title => 'Application name',
		        		required => 'true',
		        	},
		        	value => {
		        		type => 'string',
		        		title => 'Application location',
		        		required => 'true',
		        	},
		        		
		            	
	        }
		
	};
}


1;
__DATA__

=head1 NAME

ZOE::Runtime::EnvironmentVariable

=head1 Description

Represents environment varaibles set on applicaiton startup

        name        => undef, #Variable name
        value       => undef, #variable value       


=head1 Author
    
dinnibartholomew@gmail.com
    
=cut

