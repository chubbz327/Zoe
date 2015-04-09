package Zoe::ZoeActionController;
use Zoe::ZoeController;
our @ISA = qw(Zoe::ZoeController);
use Env;
use FindBin;
use Data::Dumper;
BEGIN { unshift @INC, "$FindBin::Bin/../" }


my $limit	= $ENV{ZOE_DISPLAY_LIMIT} || 10;

sub delete {
    my $self    = shift;
   
  
    $self->SUPER::delete();    
    return;
}
sub search {
	my $self 		= shift;
	my $template	=  'zoe/show_all';
	my $limit		= 10;
	
	$self->SUPER::search(   template => $template, limit => $limit, layout=>'zoe' );
	return;	     
}

sub show_all {
    my $self    = shift;
	my $template	=  'zoe/show_all';
	my $limit		= 10;
    $self->SUPER::show_all(  template => $template, limit => $limit, layout=>'zoe' );
	 
	return; 
}

sub show {
    my $self    = shift;
	my $template	= 'zoe/show';
	
	$self->SUPER::show(  template => $template,, layout=>'zoe' );
	return;
}



sub create {
    my $self    = shift;   
   
    my $url		= $self->url_for(
									$self->param('route_name')
								);       
	$self->SUPER::create(  url => $url,);
	return;

}
sub update {
    my $self    = shift;   
   
    my $url		= $self->url_for(
									$self->param('route_name')
								);       
	$self->SUPER::update(   url => $url);
	return;
}
sub show_edit {
    my $self    = shift; 
    my %args 	= @_;
       
    my $template= $args{template} || 'zoe/create_edit';
    $self->SUPER::show_create_edit(  template => $template, 
    		object_action => '_update',  layout=>'zoe');
    return;
}
sub show_create {
    my $self     = shift;
    my %args 	= @_;
       
    my $template= $args{template} ||  'zoe/create_edit';
	$self->SUPER::show_create_edit(  template => $template, 
	object_action => '_create',  layout=>'zoe');
    return;
}




1;

