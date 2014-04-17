package #__PACKAGENAME__;
#__USESTATEMENTS__



use Zoe::ZoeController;
our @ISA = qw(Zoe::ZoeController);
use Env;
use FindBin;
use JSON::Parse 'json_to_perl';
use Data::Dumper;
BEGIN { unshift @INC, "$FindBin::Bin/../" }
use #__OBJECTNAME__;

use Data::GUID;

my $type  	= '#__OBJECTNAME__'; 
my $limit	= $ENV{ZOE_DISPLAY_LIMIT} || 10;

sub delete {
    my $self    = shift;
    my $message	= '#__OBJECTNAME__ deleted';
    $self->SUPER::delete(type=> $type, message => $message);    
    return;
}
sub search {
	my $self 		= shift;
	my $template	=  '#__TEMPLATEDIR__/show_all';
	my $limit		= 10;
	
	$self->SUPER::search(type => $type, template => $template, limit => $limit );
	return;	     
}

sub show_all {
    my $self    = shift;
	my $template	=  '#__TEMPLATEDIR__/show_all';
	my $limit		= 10;
    $self->SUPER::show_all(type => $type, template => $template, limit => $limit );
	return; 
}

sub show {
    my $self    = shift;
	my $template	= '#__TEMPLATEDIR__/show';
	
	$self->SUPER::show(type =>$type, template => $template);
	return;
}



sub create {
    my $self    = shift;   
    my $message = $self->_get_short_name($type) . 'created';
    my $url		= $self->url_for(
									$self->param('route_name')
								);       
	$self->SUPER::create(type =>$type, message => $message, url => $url);
	return;

}
sub update {
    my $self    = shift;   
    my $message = $self->_get_short_name($type) . 'created';
    my $url		= $self->url_for(
									$self->param('route_name')
								);       
	$self->SUPER::update(type =>$type, message => $message, url => $url);
	return;
}
sub show_edit {
    my $self    = shift;    
    my $template= '#__TEMPLATEDIR__/show_edit';
    $self->SUPER::show_edit(type =>$type, template => $template);
    return;
}
sub show_create {
    my $self     = shift;
    my $template = '#__TEMPLATEDIR__/show_create';
	$self->SUPER::show_create(type =>$type, template => $template);
    return;
}

sub check_unique {
	my $self = shift;
	my $column 	= $self->param('COLUMN');
	my $value 	= $self->param('VALUE');
 	
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

