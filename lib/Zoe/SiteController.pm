package Zoe::SiteController;

use Mojo::Base 'Zoe::ZoeController';
use FindBin;
use JSON::Parse 'json_to_perl';
use Data::Dumper;
use Digest::SHA1 qw(sha1_hex);
use Data::Dumper;
use Mojo::Exception;
use Class::MOP;


BEGIN { unshift @INC, "$FindBin::Bin/../";
        unshift @INC, "$FindBin::Bin/../handlers";
      }
use Data::GUID;

my $layout = 'zoe';

sub pass_to_handler {
    my $self = shift;
    my $runtime = $self->get_runtime();
    
    my $current_route = $self->current_route;
    
    my @sites;
    
    #validate 
    if ($runtime->{sites}) {
        @sites = @{ $runtime->{sites} };
    } else {
        $self->log('error', 'No sites defined in Runtime');
        return;
    }
    
    #find the correct handler
    foreach my $site (@sites) {
        my @routes = @{ $site->{routes} };
        
        foreach my $route (@routes) {
            if ( $route->{name} eq $current_route) {
              #send to handler
              $self->log('debug', $route->{name} . " matches $current_route");
              my $handler = $route->{handler};
              my $handler_method = $route->{handler_method};
             
              Class::MOP::load_class($handler) or
                 Mojo::Exception->throw("Could not require $handler");     
              print Dumper @INC;
               $self->log('debug', "Handler: $handler hanlder_method: $handler_method ");
              return ($handler->new()->$handler_method($self) );                
            }
        }
        
        
    }
    $self->log('error', "No Handler found for $current_route");
    return;
}

  
    


1;
