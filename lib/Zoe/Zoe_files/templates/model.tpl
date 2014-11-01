package #__TYPE__;
use strict;
use warnings;
use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/#__LIB_PATH__" }
use Zoe::DataObject;
use parent qw( Zoe::DataObject);


sub new {
    #set table definitions
    my $sql = {};

    #get the table name from the package  name
    my $table_name = __PACKAGE__;

    #remove the prefix to package name
    $table_name =~ s/.*::(\w+)$/$1/;
    #set the table name
    $sql->{TABLE} = '#__TABLENAME__';

    #set the table definitions
    @{ $sql->{COLUMNS} } = qw(#__COLUMNS__);

    #define the primary key
    $sql->{PRIMARYKEY} = qq/#__PRIMARYKEY__/;

    #set the foreign kyes
    #__FOREIGNKEY__
    #set has many relationships
    #__HASMANY__

    #set has manytomany relationships
	my $many_description;
    #__MANYTOMANY__

    my $type = shift;
    my $self = __PACKAGE__->SUPER::spawn( @_, SQL => $sql );
    return bless $self;
}
sub get_column_info {
	my $self =shift;	
	my @column_info = (
		#__COLUMNINFO__ 
	);
	return @column_info;
}

sub get_route {
	my $self 	= shift;
	return '#__ROUTE__';
}

sub get_display_as_for {
	my $self = shift;
	my $column_name = shift;
	my %display_as = (
		#__DISPLAYAS__
	
	);
	
	return $display_as{$column_name} || $column_name;	 
}


sub get_select_options_for {
	my $self = shift;
	my $column_name = shift;
	my %select_options = (
		#__SELECTOPTIONS__
	);
	return $select_options{$column_name};
	
}


sub get_linked_create {
	my $self = shift;
	my $linked_create = {
		#__LINKEDCREATE__
	}; 
	return $linked_create;
}


sub get_searchable_columns {
	my $self = shift;
	my @searchable_columns = (
		#__SEARCHABLECOLUMNS__
	);
	return @searchable_columns;
}

sub is_required_column {
    my $self = shift;
    my $column = shift;
    my %required_column = (
    
        #__ISREQUIRED__
    
        );        
    return $required_column{$column} if ( defined($required_column{$column}) );    
    return undef;
}


sub get_column_display {
    my $self = shift;
    my $column = shift;
    my %display = (
    
        #__COLUMNDISPLAY__
    
        );
        
    return $display{$column} if ( defined($display{$column}) );
    
    return undef;
}

sub to_string {
	my $self = shift;
	return $self->{
	 '#__TOSTRINGMEMBER__' 
	};

}	
sub get_to_string_member {
	my $self = shift;
	
	
	 return '#__TOSTRINGMEMBER__';

}

sub get_upload_path {
	my $self = shift;
	return "$FindBin::Bin/../public/" . '#__UPLOADPATH__';	 
}

sub get_public_upload_path {
	my $self = shift;
	return '#__PUBLICUPLOADPATH__';
}

sub is_auth_object{
	my $self =  shift;
	return #__ISAUTHOBJECT__;
	
}

sub auth_object_info {
	my $self = shift;
	
	return qw(#__AUTHOBJECTINFO__ );
		 
}

sub get_no_select {
    my $self = shift;
    return (#__NOSELECT__);
	 
}
sub get_object_name_short_hand {
	my $self = shift; 
	return '#__OBJECTNAMESHORT__';
}





1;
