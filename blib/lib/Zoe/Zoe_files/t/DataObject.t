#!/usr/bin/perl
package TestObject3;

use strict;
use warnings;
use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }
use Zoe::DataObject;
use parent qw( Zoe::DataObject);
use Data::Dumper;

sub new {
    #set table definitions
    my $sql = {};

    #get the table name from the package  name
    my $table_name = __PACKAGE__;

    #remove the prefix to package name
    $table_name =~ s/.*::(\w+)$/$1/;
    #set the table name
    $sql->{TABLE} = $table_name;

    #set the table definitions
    @{ $sql->{COLUMNS} } = qw(name ID);

    #define the primary key
    $sql->{PRIMARYKEY} = qq/ID/;

    $sql->{MANYTOMANY}->{TestObject2} = [ {
        table            => 'TestObject2XTestObject3',
        my_column        => 'TestObject3_ID',
        relationship_col => 'TestObject2_ID',
        member           => 'TestObject2_LIST',
        primary_key      => 'ID',
    } ];

    my $type = shift;
    my $self = __PACKAGE__->SUPER::spawn( @_, SQL => $sql );
    return bless $self;

}
1;

package TestObject2;

use strict;
use warnings;
use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }
use Zoe::DataObject;
use parent qw( Zoe::DataObject);
use Data::Dumper;

sub new {
    #set table definitions
    my $sql = {};

    #get the table name from the package  name
    my $table_name = __PACKAGE__;

    #remove the prefix to package name
    $table_name =~ s/.*::(\w+)$/$1/;

    #set the table name
    $sql->{TABLE} = $table_name;

    #set the table definitions
    @{ $sql->{COLUMNS} } = qw(name TestObject1_ID ID);

    #define the primary key
    $sql->{PRIMARYKEY} = qq/ID/;

    #define foreign keys
    #rel type        		#column         #object type		#member
    $sql->{FOREIGNKEY}->{TestObject1_ID}->{'TestObject1'} =  'TestObject1';

    $sql->{MANYTOMANY}->{TestObject3} = [{
        table            => 'TestObject2XTestObject3',
        my_column        => 'TestObject2_ID',
        relationship_col => 'TestObject3_ID',
        member           => 'TestObject3_LIST',
        primary_key      => 'ID',
    }];

    my $type = shift;

    my $self = __PACKAGE__->SUPER::spawn( @_, SQL => $sql );

    return bless $self;

}
1;

package TestObject1;

use strict;
use warnings;
use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }
use Zoe::DataObject;
use parent qw( Zoe::DataObject );
use Data::Dumper;

sub new {

    #table definitions

    #set table definitions
    my $sql = {};

    #get the table name from the package  name
    my $table_name = __PACKAGE__;

    #remove the prefix to package name
    $table_name =~ s/.*::(\w+)$/$1/;

    #set the table name
    $sql->{TABLE} = $table_name;
    #set the table definitions
    @{ $sql->{COLUMNS} } = qw(name ID );

    #define the primary key
    $sql->{PRIMARYKEY} = qq/ID/;

    #define HASMANY releationships
    #rel type        #column         #object type
    $sql->{HASMANY}->{TestObject2} =[{TestObject2_LIST => 'TestObject1_ID'} ];

    my $type = shift;
    my $self = __PACKAGE__->SUPER::spawn( @_, SQL => $sql );

    #return bless $self;
    return bless $self;

}
1;

package main;
use v5.10;
use Mojo::Base -strict;
use Data::Dumper;
use Test::More 'no_plan';
use Test::Mojo;
use FindBin;
use List::MoreUtils qw(any);


MAIN: {

    my (
        $to1,           #TestObject1
        $to1_a,         #TestObject1
        $to1_b,         #TestObject1
        
        $to2,           #TestObject2
        $to2_a,         #TestObject2
        $to2_b,         #TestObject2

        $to3,           #TestObject3
        $to3_a,         #TestObject3

        @to1s,          #arrray for storing TestiObject1 ojbects
        @compare_to1s,  #arrray for comaparing TestiObject1 ojbects
        
        @to2s,          #arrray for storing TestiObject1 ojbects
        @compare_to2s,  #arrray for comaparing TestiObject1 ojbects

        @to3s,          #arrray for storing TestiObject1 ojbects
        @compare_to3s,  #arrray for comaparing TestiObject1 ojbects
        $check_pkey,      #temporary variable storing primary keys 
        $num_matches,
		%where,
		$order_by,
		$limit,
    );
    BEGIN {
###########################################
####confirm the Zoe::DataObject loads
############################################
        unshift @INC, "$FindBin::Bin/../lib";
#1
        use_ok('Zoe::DataObject',
        'Zoe::DataObject loaded');
    }


##############################################
####Create tables
##############################################

#2 Get database handle and confirm active

    my $do  = Zoe::DataObject->new();
    my $dbh = $do->get_database_handle();
    ok ($dbh->{Active},
        "->get_database_hande " . $do->{TYPE} );

#3-10   DDL
    my @table_sqls = (
        'drop table if exists TestObject1',
        'create table  TestObject1 (
                 ID INTEGER PRIMARY KEY NOT NULL,
                  name varchar(100) DEFAULT NULL)',
        'drop table if exists TestObject2',
        'create table  TestObject2 (
                 ID INTEGER PRIMARY KEY NOT NULL,
                  name varchar(100) DEFAULT NULL,
                  TestObject1_ID INTEGER )',
        'drop table if exists TestObject3',
        'create table  TestObject3 (
                 ID INTEGER PRIMARY KEY NOT NULL,
                  name varchar(100) DEFAULT NULL) ',
        'drop table if exists TestObject2XTestObject3',
         'create table  TestObject2XTestObject3 (
                  TestObject2_ID INTEGER,
                  TestObject3_ID INTEGER,
                 ID INTEGER PRIMARY KEY NOT NULL)',
    );

    foreach my $stmt (@table_sqls) {
        my $rv = $dbh->do($stmt);
        ok( $rv, "Initialization SQL successfull :\n\t$stmt" );
    }

#11 Creating and Saving 
    $to1 = TestObject1->new( name => 'TestObject1_1' );
    $to1->save();
        ok( $to1->{ID},
        "->save -NO RELATIONSHIP");

#12 Updating Saving
    $to1->set_name("TestObject1_1_updated");
    $to1->save();
    $to1    = $to1->reload();

    ok($to1->get_name() eq 'TestObject1_1_updated', 
        "->reload -NO RELATIONSHIP
         -> update successfull");
    
#13 Querying BY
    $to1_a  = TestObject1->new( name => 'TestObject1_1a');
    $to1_a->save();
    $check_pkey = $to1_a->get_ID();
	
	$where{name} = 'TestObject1_1a';
    $to1_a  = ( TestObject1->find_by(
                            where => \%where
                            )
              )[0];
    ok($check_pkey == $to1_a->get_ID(),
        '->load_by
         -> ObjectName->find_by NO RELATIONSHIP');

#14 Load all

    @to1s = TestObject1->find_all();
	 
    ok( scalar(@to1s) == 2,
        '->load_all
         ->ObjectName->find_all NO RELATIONSHIP');
    $num_matches = 0;
    $num_matches++
    if any { $_->get_ID() == $to1->get_ID() } @to1s;

    $num_matches++
    if any {  $_->get_ID() == $to1_a->get_ID() } @to1s;
#15
    ok($num_matches == 2, 
        '>load_all
         ->ObjectName->find_all 
            Content Matches - NO RELATIONSHIP');

#16 Delete
    # previously 
    # $check_pkey = $to1_a->get_ID();
$to1_b = TestObject1->new({name => 'to be deleted'});
$to1_b->save();
 $check_pkey = $to1_b->get_ID();
    
     $to1_b->delete();
    ok (!  TestObject1->new->load($check_pkey) ,
        '-> delete 
             - NO RELATIONSHIP');

#####################################################
#
# HASMANY - 1 to many relationships
#
######################################################

#17 Set and Save
    $to2 = TestObject2->new( { name => 'TestObject2_1' } );
    $to2->set_TestObject1($to1);
    $to2->save();
    $to1 = $to1->reload();
   
    #first element in array  
    ok( ( $to1->get_TestObject2_LIST() )[0]->get_ID() 
            == $to2->get_ID(), 
        '->set_<OBJECT NAME> LIST FOREIGN KEY 
         ->get_<OBJECT NAME> LIST HASMANY' 
      ); 

#18 Adding
    $to2_a  = TestObject2->new( { name => 'TestObject2_1a' } );
    # automatically saves onces added
    $to1->add_to_TestObject2_LIST($to2_a);
	$to1->save();
    @to2s    = $to1->get_TestObject2_LIST();

    $num_matches = 0;
    $num_matches++
    if any { $_->get_ID() == $to2->get_ID() } @to2s;

    $num_matches++
    if any {  $_->get_ID() == $to2_a->get_ID() } @to2s;
    
    ok($num_matches == 2,
        '->add_<ObjectName> LIST HASMANY
            Content Matches - ');
#19 Seting passing and array
    #removes previoius relationship
    #then adds new
    #saves child on save
    $to2_b  = TestObject2->new( { name => 'TestObject2_1b' } );
    @to2s   = ($to2, $to2_a, $to2_b);
    $to1_a->set_TestObject2_LIST( \@to2s);
    $to1_a->save();

    @to2s   = $to1_a->get_TestObject2_LIST();
    $to1    = $to1->reload();
    @compare_to2s = $to1->get_TestObject2_LIST();

    ok( ! @compare_to2s, 
        '->set_<ObjectName> LIST HASMANY
            removes the previous relationship');
    
    $to2    = $to2->reload();
    $to2_a  = $to2_a->reload();
    $to2_b  = $to2_b->reload();
    
    $num_matches = 0;
    $num_matches++
    if any { $_->get_ID() == $to2->get_ID() } @to2s;

    $num_matches++
    if any {  $_->get_ID() == $to2_a->get_ID() } @to2s;

    $num_matches++
    if any {  $_->get_ID() == $to2_b->get_ID() } @to2s;

#20
    ok($num_matches == 3,
        '->set_<ObjectName> LIST HASMANY
            Content Matches - ');

#21 Remove Object from HASMANY
    $to1_a->remove_from_TestObject2_LIST($to2_b);
    $to1_a->save();
 
    @to2s   = $to1_a->get_TestObject2_LIST();
	
	
    $num_matches = 0;
    $num_matches++
    if any { $_->get_ID() == $to2->get_ID() } @to2s;

    $num_matches++
    if any {  $_->get_ID() == $to2_a->get_ID() } @to2s;

    $num_matches++
    if any {  $_->get_ID() == $to2_b->get_ID() } @to2s;

    ok($num_matches == 2,
        '->remove_<ObjectName> LIST HASMANY
            Content Matches - ');   

    $to2_b = $to2_b->reload();
###########################################################
#
# MANYTOMANY
#
###########################################################

    #add MANYTOMANY
    #    

    $to3 = TestObject3->new( { name => 'TestObject3_1' } );
    $to3->add_to_TestObject2_LIST($to2);
    $to3->add_to_TestObject2_LIST($to2_a);
    $to3->save();
	$to3->reload;


    @to2s = $to3->get_TestObject2_LIST();

	#print Dumper $to3;
    $num_matches = 0;
    $num_matches++
    if any { $_->get_ID() == $to2->get_ID() } @to2s;

    $num_matches++
    if any { $_->get_ID() == $to2_a->get_ID() } @to2s;

#22
    ok($num_matches == 2,
        '->add_<ObjectName> LIST MANYTOMANY
         ->get_<ObjectName> LIST
            Content Matches - ');

    #Remove and confirm
    $to3->remove_from_TestObject2_LIST($to2);
    $to2 = $to2->reload();
    $to3->save(); 

    @to2s = $to3->get_TestObject2_LIST();
    $num_matches = 0;
    $num_matches++
    if any { $_->get_ID() == $to2_a->get_ID() } @to2s;

#23 Remove check
    ok($num_matches == 1,
        '->remove_<ObjectName> LIST MANYTOMANY
         ->get_<ObjectName> LIST
            Content Matches - ');


#24 confirm set
    @to2s    =  ($to2, $to2_a, $to2_b);   
    $to3->set_TestObject2_LIST(\@to2s);
    $to3->save();
    @to2s   = $to3->get_TestObject2_LIST();

    $num_matches = 0;
    $num_matches++
    if any { $_->get_ID() == $to2->get_ID() } @to2s;

    $num_matches++
    if any {  $_->get_ID() == $to2_a->get_ID() } @to2s;

    $num_matches++
    if any {  $_->get_ID() == $to2_b->get_ID() } @to2s;

    ok($num_matches == 3,
        '->set_<ObjectName> LIST MANYTOMANY
            Content Matches - ');

#25 confirm bidirectonality
    $to2    = $to2->reload();
    ok( ( $to2->get_TestObject3_LIST() )[0]->get_ID() == $to3->get_ID(),
    '-> Check bidirectionality MANYTOMANY');
}

system('mv ../config ../config2');
#26 get Zoe::DataObject from DBCONFIGFILE
my $do2	= Zoe::DataObject->new(DBCONFIGFILE => 
	'/home/dinnibartholomew/script/linuxbox/scripts/Zoe/config2/db.yml');
my $dbh2	=	$do2->get_database_handle;
	
	ok( $dbh2->{Active},
		'-> DBCONFIGFILE works');
		
system('mv ../config2 ../config');
		

1;
