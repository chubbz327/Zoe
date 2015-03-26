package Zoe::DO::User;
use strict;
use warnings;
use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../../../lib" }
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
    $sql->{TABLE} = 'ZoeDOUser';

    #set the table definitions
    @{ $sql->{COLUMNS} } = qw(ID login password_hash password_salt Role_ID );

    #define the primary key
    $sql->{PRIMARYKEY} = qq/ID/;

    #set the foreign kyes
     $sql->{FOREIGNKEY}->{'Role_ID'}->{'Zoe::DO::Role'} = 'Role';
    #set has many relationships
    #__HASMANY__



    #set has manytomany relationships
	my $many_description;
    #__MANYTOMANY__



    my $type = shift;
    my $self = __PACKAGE__->SUPER::new( @_, SQL => $sql );
    return bless $self;
}
sub get_column_info {
	my $self =shift;	
	my @column_info = (
		'ID', 'integer',
'login', 'text',
'password_hash', 'text',
'password_salt', 'text',
'Role_ID', 'FOREIGNKEY',
  
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
		'ID', 'login', 'password_hash', 'password_salt', 'Role_ID', 
	);
	return @searchable_columns;
}

sub is_required_column {
    my $self = shift;
    my $column = shift;
    my %required_column = (
    
        'login' => 1 , 
'password_hash' => 1 , 
'password_salt' => 1 , 

    
        );        
    return $required_column{$column} if ( defined($required_column{$column}) );    
    return undef;
}


sub get_column_display {
    my $self = shift;
    my $column = shift;
    my %display = (
    
        'password_hash' => q^none^,
'password_salt' => q^none^,

    
        );
        
    return $display{$column} if ( defined($display{$column}) );
    
    return undef;
}

sub to_string {
	my $self = shift;
	return $self->{
	 'login' 
	};

}	
sub get_to_string_member {
	my $self = shift;
	
	
	 return 'login';

}

sub get_upload_path {
	my $self = shift;
	return "$FindBin::Bin/../public/" . 'upload/Zoe_DO_User';	 
}

sub get_public_upload_path {
	my $self = shift;
	return '/upload/Zoe_DO_User/';
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
	return 'zoe_do_user';
}





1;
