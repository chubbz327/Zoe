package Zoe::ZoePortalController;
use Zoe::ZoeController;
our @ISA = qw(Zoe::ZoeController);
use Env;
use FindBin;
use Data::Dumper;
BEGIN { unshift @INC, "$FindBin::Bin/../" }


my $limit	= $ENV{ZOE_DISPLAY_LIMIT} || 10;

sub _get_stash{
    my $self =shift;
    
    
    my $route_name = $self->match->endpoint->name;
    
   # print $self->match->endpoint->name . " HERER\n\n";
    
    my $stash = $self->stash($route_name .'stash');
    my %stash = ();
    %stash = %{$stash} if ($stash);
    
    return %stash;
}

 
sub delete {
    my $self    = shift;
   
    $self->SUPER::delete($self->_get_stash() );    
    return;
}

sub search {
	my $self 		= shift;
 
    
	$self->SUPER::search(  $self->_get_stash() );
	return;	     
}

sub show_all {
    my $self    = shift;
 
    
    #my %stash = $self->_get_stash();
   # print Dumper $self->stash();
    #print Dumper \%stash;   
    $self->SUPER::show_all( );
	 
	return; 
}

sub show {
    my $self    = shift;
	my $template	= 'zoe/show';
	
	$self->SUPER::show(  template => $template, layout=>'zoe' );
	return;
}



sub create {
    my $self    = shift;   
   
    my $url		= $self->url_for(
									$self->param('route_name')
								);       
	$self->SUPER::create(  url => $url, $self->_get_stash());
	return;

}
sub update {
    my $self    = shift;   
   
    my $url		= $self->url_for(
									$self->param('route_name')
								);       
	$self->SUPER::update(   url => $url, $self->_get_stash());
	return;
}
sub show_edit {
    my $self    = shift; 
 
    $self->SUPER::show_create_edit(  $self->_get_stash() );
    return;
}
sub show_create {
    my $self     = shift;
   
	$self->SUPER::show_create_edit( $self->_get_stash());
    return;
}




1;

