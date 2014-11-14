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
             
              eval "use $handler"; 
               $self->log('debug', "Handler: $handler hanlder_method: $handler_method ");
              return ($handler->new()->$handler_method($self) );                
            }
        }
        
        
    }
    $self->log('error', "No Handler found for $current_route");
    return;
}
sub _init {
    my $self = shift;
    my $type = $self->param('__TYPE__');
    eval "use $type";    
   
    
}






my $limit   = $ENV{ZOE_DISPLAY_LIMIT} || 10;

sub delete {
    my $self    = shift;
    my $message = 'CompassionRoads::Role deleted';
  
    $self->SUPER::delete( message => $message, 
    object_action => '_delete');    
    return;
}
sub search {
    my $self        = shift;
    my $template    =  'zoe/show_all';
    my $limit       = 10;
    
    $self->SUPER::search( template => $template, limit => $limit );
    return;      
}

sub show_all {
    my $self    = shift;
    my $template    =  'zoe/show_all';
    my $limit       = 10;
    $self->SUPER::show_all( template => $template, limit => $limit );
    return; 
}

sub show {
    my $self    = shift;
    my $template    = 'zoe/show';
    
    $self->SUPER::show( template => $template, );
    return;
}



sub create {
    my $self    = shift;   

    my $url     = $self->url_for(
                                    $self->param('route_name')
                                );       
    $self->SUPER::create(  url => $url,);
    return;

}
sub update {
    my $self    = shift;   
  
    my $url     = $self->url_for(
                                    $self->param('route_name')
                                );       
    $self->SUPER::update( url => $url);
    return;
}
sub show_edit {
    my $self    = shift; 
    my %args    = @_;
       
    my $template= $args{template} || 'zoe/create_edit';
    $self->SUPER::show_create_edit( template => $template, 
            object_action => '_update');
    return;
}
sub show_create {
    my $self     = shift;
    my %args    = @_;
       
    my $template= $args{template} ||  'zoe/create_edit';
    $self->SUPER::show_create_edit( template => $template,  object_action => '_create');
    return;
}

sub check_unique {
    my $self = shift;
    my $column  = $self->param('COLUMN');
    my $value   = $self->param('VALUE');
    my $type= $self->stach('__TYPE__');
    
    my $return = scalar( $type->find_by(where=>{$column => $value }) );
    
    $return = 0 unless ($value);
    
    
    if ( $self->req->is_xhr ) {
        $self->render( json => $return);
    }
    else {
        $self->redirect_to($return);
    }
     
}




  
    


1;
