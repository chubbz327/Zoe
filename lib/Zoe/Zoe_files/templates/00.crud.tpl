#!/usr/bin/env perl
use v5.10;
use Mojo::Base -strict;
use Data::Dumper;
use Test::More 'no_plan';
use Test::Mojo;
use FindBin;
use List::MoreUtils qw(any);
use Mojo::Asset::File;
use DateTime;
use DateTime::Format::DBI;

$ENV{MOJO_LOG_LEVEL}="debug";

my $v_tmp;    #temporary var used for comparison
my $where;    #used for finds
my $ADMINUSER = 'admin';
my $ADMINPASS = 'test';

my @tmp_list;

###########################################
####confirm the Zoe::DataObject loads
############################################
unshift @INC, "$FindBin::Bin/../lib";
unshift @INC, "$FindBin::Bin/../../../../lib";


#1
use_ok( 'Zoe::DataObject', 'Zoe::DataObject loaded' );

#
my $t = Test::Mojo->new('#__APPLICATIONNAME__');
$t->app->log->level('debug');


###########################################
####confirm the created objects load
############################################

my @objects_to_test = (

    #__TESTUSELIST__

);
foreach my $object_type (@objects_to_test) {
    use_ok( $object_type, "$object_type loaded" );
}

###########################################
####create new instances of ojbect
############################################
#__OBJECTCREATE__

###########################################
####set values for foreign keys
############################################

#__SETFOREIGNKEYCODE__

###########################################
####save objects
############################################
#__SAVETESTCODE__

###########################################
####test update objects
####test find by column type
############################################
#__UPDATETESTCODE__

###########################################
####find by primary key
############################################

#__FINDBYPK__
#######
#__TESTSTATEMENTS__

####################################
####Web tests
####################################
#log in 
    $t->post_ok('/__ADMIN__/login'  =>form =>{user=>$ADMINUSER, password=>$ADMINPASS})
    ->status_is(302, "log in successfull");
#make sure / works
$t->get_ok( '/#__URLPREFIX__', '#__APPLICATIONNAME__ is up' )
  ->status_is( 200, '#__APPLICATIONNAME__ returned 200 for /' );

#test find all and object by pkey via http
#__TESTSHOW__

#test update and create object
#__TESTPOST__

sub post_data {
    my $url_string  = shift;
    my $object = shift;
    #my $do               = Zoe::DataObject->new();
    my %has_many_value   = ();
    my $form             = {}; 
    my $random_string;
    my %has_many_member = $object->get_has_many_info();
    my %many_member     = $object->get_many_to_many_info();
    my %all_many    = (%has_many_member, %many_member);
    my @columns          = $object->get_column_names();
    my $pk_member        = $object->get_primary_key_name;
    my %column_info      = $object->get_column_info;
    
        my $message = 'Created new ' . $object->get_object_type; 

    foreach my $column_name (@columns) {
    	if ($object->is_auth_object()){
    		my %auth_info = $object->auth_object_info();
    		
    		next if ($column_name eq $auth_info{password_member});
    	}
        if ( $pk_member eq $column_name ) {   #pk field set on update not create
            if ( $object->get_primary_key_value ) {

                #object already saved
                $form->{$column_name} = $object->get_primary_key_value;
                $message = "Updated " . $object->get_object_type . " with primary key of " . $object->get_primary_key_value;
                next;
            }
        }
        my $fk_type = $object->get_foreign_key_type($column_name);
        if ($fk_type) {
            my @list = $fk_type->find_all();
            $form->{$column_name} = $list[0]->get_primary_key_value;
        }
        elsif ($column_info{$column_name} =~ /file/i) {
                my $file = Mojo::Asset::File->new->add_chunk('lalala'); 
                $form->{$column_name}={file=>$file, filename=>'x'};
                } elsif ( ($column_info{$column_name} =~ /^time.*/i  ) ||  ($column_info{$column_name} =~ /^date.*/i) ){
        
            my $db_parser = DateTime::Format::DBI->new( $object->get_database_handle() );
                    my $dt = DateTime->now();
                    $random_string = $db_parser->format_datetime($dt);                     $form->{$column_name} = $random_string;
        }                else {
             $random_string =  int(rand(10000)) ;
            $form->{$column_name} = $random_string;
        }

    }
    
    foreach my $member ( keys(%all_many)) {
        my $type = $all_many{$member};
        my @list = $type->find_all();
         if(scalar (@list)) {
             my @ids = ($list[$#list]->get_primary_key_value);
             $form->{$member} = \@ids;
         }               }
    
        #print "Posting to $url_string\n";
    $t->post_ok($url_string  =>form =>$form)
    ->status_is(302, $message . " $url_string");
    

}

0;
