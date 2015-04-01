#!/usr/local/perl/perl-5.16.0/bin/perl
use strict;
use warnings;
my $is_verbose = 0;

package Zoe::DataObject::Logger;
use FindBin;

use Mojo::Base 'Mojolicious';
use Mojo::Log;
use Path::Class;
use Data::Dumper;
use Env;


sub debug
{
 $ENV{MOJO_MODE} = 'development' unless($ENV{MOJO_MODE});
 my $log_dir = dir ( "$FindBin::Bin", '..', 'log',);
 return unless (-e "$log_dir");
 my $log_file = file( "$FindBin::Bin", '..', 'log', $ENV{MOJO_MODE} . '.log' );
 my $logger  = Mojo::Log->new( path=>"$log_file" );
 my $caller  = ( caller(1) )[3];
 my $message = __PACKAGE__ . ':' . $caller . ': ' . shift;
 my $method  = 'debug';

  $logger->debug( $message); 
  
}

package Zoe::Connection;
use Carp;
use DBI;
use Data::Dumper;

#use Log::Message::Simple qw[msg error debug];
use FindBin;
use strict;
use warnings;

my $singleton;
my $DBTYPE = undef;

sub new
{
 my @all_args = @_;
 my $type     = shift(@all_args);
 my %arg      = @all_args;
 return $singleton if ($singleton);
 my $self = {};

 #my $environment = ($ENV{ZOE_ENV} or 'development');

 my ( $config, $dbfile, $host, $dbuser, $dbpassword, $dbname, $port, $runtime );

 #read config info from var
 $self->{TYPE} = $type;

 $runtime = $arg{runtime};
 unless ($runtime)
 {

  #Read in config from param or use default
  #config/db.yml file
  $config = $arg{DBCONFIGFILE}
    || "$FindBin::Bin/../config/runtime.yml";
  confess "Could not read config file: $config" unless ( -e $config );
  $runtime = YAML::XS::LoadFile($config) or croak "malformed YAML: $config";
 }

 $host       = $runtime->{database}->{host};
 $port       = $runtime->{database}->{port};
 $dbuser     = $runtime->{database}->{dbuser};
 $dbpassword = $runtime->{database}->{dbpassword};
 $DBTYPE     = $runtime->{database}->{type};
 $dbname     = $runtime->{database}->{dbname};
 $dbfile     = $runtime->{database}->{dbfile};
 $is_verbose = $runtime->{database}->{is_verbose} || 0;

 my $dsn = undef;

 #mysql database connection
 #if ( $DBTYPE eq 'mysql' ) {

 #}

 #sqlite3 database connection
 if ( $DBTYPE eq 'sqlite' )
 {
  croak "Database file: $dbfile does not exist"
    unless ( -e $dbfile );

  $dsn = "dbi:SQLite:dbname=$dbfile";
  $self->{DBH} = DBI->connect( $dsn, "", "" )
    or confess "Can't connect to database: ", $DBI::errstr;
  
 } else
 {
  $dsn = "DBI:$DBTYPE:database=$dbname;host=$host;port=$port";
  $self->{DBH} = DBI->connect( $dsn, $dbuser, $dbpassword )
    or confess "Can't connect to database: ", $DBI::errstr;
 }
 bless( $self, $type );
 $singleton = $self;
 return $self;
}

sub get_DBH
{
 my $self = shift;
 my $dbh  = $self->{DBH};
 if ( ( defined($dbh) ) && ( $dbh->{Active} ) )
 {
  return $self->{DBH};
 } else
 {
  return __PACKAGE__->new()->get_DBH();
 }
 return $dbh;
}
1;

package Zoe::DataObject;
use strict;
use Carp;
use warnings;
use DBI;
use Data::Dumper;
use SQL::Abstract::More;

#use Log::Message::Simple qw[msg error debug];

my ( $sql_builder, $DBConnection );

sub get_database_handle
{
 my $self = shift;
 return $self->{DBH};
}

sub _delete_to_many
{
 my $self = shift;
 my $dbh  = $DBConnection->get_DBH();
 my %sql  = %{ $self->{SQL} };
 return unless $sql{MANYTOMANY};
 my %to_many = %{ $sql{MANYTOMANY} };
 my (%where);

 foreach my $object_name ( keys(%to_many) )
 {
  my @list = @{ $to_many{$object_name} };
  for ( my $i = 0 ; $i <= $#list ; $i++ )
  {
   my %rel         = %{ $to_many{$object_name}->[$i] };
   my $rel_table   = $rel{table};
   my $my_col      = $rel{my_column};
   my $rel_col     = $rel{relationship_col};
   my $member      = $rel{member};
   my $table_pkey  = $rel{table_primary_key} || 'ID';
   my %rel_to_pkey = ();

   if ( $self->{$member} )
   {
    %rel_to_pkey = %{ $self->{$member} };
   }

   $where{$my_col} = $self->get_primary_key_value;

   my ( $cmd, @bind ) = $sql_builder->delete( $rel_table, \%where );
   Zoe::DataObject::Logger::debug(
                                     "deleting MANYTOMANY for " . $self->{TYPE},
                                     $is_verbose );

   Zoe::DataObject::Logger::debug( $cmd, $is_verbose );
   my $sth = $dbh->prepare($cmd);
   $sth->execute(@bind);

  }
 }
 return;
}

sub get_table_name
{
 my $self = shift;
 my %sql  = %{ $self->{SQL} };

 #Build sql
 my $table_name = $sql{'TABLE'};

 return $table_name;
}

sub delete
{
 my $self = shift;
 my $dbh  = $DBConnection->get_DBH();

 my %sql = %{ $self->{SQL} };

 #Build sql
 my $table_name = $sql{'TABLE'};
 if ( $sql{HASMANY} )
 {
  my %has_many = %{ $sql{HASMANY} };
  foreach my $type ( keys(%has_many) )
  {
   my @list = @{ $has_many{$type} };

   for ( my $i = 0 ; $i <= $#list ; $i++ )
   {
    my %map = %{ $has_many{$type}->[$i] };
    my ( $member, $column ) = each(%map);
    eval {
     my @collection = ();
     $self->_load_has_many( member => $member );
     @collection = @{ $self->{$member} }
       if ( @{ $self->{$member} } );
     foreach my $obj (@collection)
     {
      $obj->{$column} = $self->get_primary_key_value();
      $obj->delete();
     }
     Zoe::DataObject::Logger::debug(
                                       "$type ------- $member, ------, $column",
                                       $is_verbose );
    };

   }
  }
 }
 my $cmd =
     "delete from $table_name where "
   . $sql{PRIMARYKEY} . "="
   . $self->get_primary_key_value();

 Zoe::DataObject::Logger::debug( "$cmd", $is_verbose );
 my $sth = $dbh->prepare($cmd);
 $sth->execute();

 $self->_delete_to_many;

 undef %{$self};
 return;
}
############################################
# Usage      : static method
# Purpose    : static wrapper for new
# Returns    : new object
# Parameters : n/a
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
sub spawn
{
 return new(@_);    ## no critic
}
############################################
# Usage      : constructor
# Purpose    : create and add add methods to
#				new object instance
# Returns    : new object
# Parameters : n/a
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a

my $connect;    #database connection
my $logger;
my $debug_fh;

sub new
{

 my (
  %arg,         #arguments
  $type,        #object type

 );
 $type = shift;

#print "$type\n\n";
 #if  hash ref
 ( ( ref( $_[0] ) eq 'HASH' ) || ( @_ % 2 != 0 ) )
   ?            # if called via super
   ( %arg = %{ shift() } and $arg{ $_[0] } = $_[1] )
   :            #the sql hash ref is stored
                #in $_{0} key - $_{1} val
                #after the shifts
   ( %arg = @_ );

 $connect = Zoe::Connection->new( runtime => $arg{runtime} ) ;#unless ($connect);
 
 my $self = {
              TYPE => $type,
              DBH  => $connect->get_DBH(),
              ID   => undef,
              %arg,
 };
 #$self->{DBH} = $connect->{DBH};

 $DBConnection = $connect;
 $sql_builder  = SQL::Abstract::More->new;

 # Dynamically generate accessor methods for child objects

 #Set Utility Methods common to all instances

 no strict 'refs';

 if (    ( defined( $self->{SQL} ) )
      && ( defined( $self->{SQL}->{PRIMARYKEY} ) ) )
 {
  my $get_primary_key_value = $type . '::get_primary_key_value';
  my $set_primary_key_value = $type . '::set_primary_key_value';
  my $get_primary_key_name  = $type . '::get_primary_key_name';
  my $pkey_name             = $self->{SQL}->{PRIMARYKEY};
  my $get                   = $type . '::get_' . $pkey_name;
  my $set                   = $type . '::set_' . $pkey_name;

  *{$get_primary_key_value} = sub {
   my $self    = shift;
   my $pk_name = $self->{SQL}->{PRIMARYKEY};
   return $self->{$pk_name};
    }
    unless ( defined( &{$get_primary_key_value} ) );

  *{$set_primary_key_value} = sub {
   my $self    = shift;
   my $pk_name = $self->{SQL}->{PRIMARYKEY};
   $self->{$pk_name} = shift;
    }
    unless ( defined( &{$set_primary_key_value} ) );

  *{$get_primary_key_name} = sub {
   my $self    = shift;
   my $pk_name = $self->{SQL}->{PRIMARYKEY};
   return $pk_name;
    }
    unless ( defined( &{$get_primary_key_name} ) );

  *{$get} = sub {
   my $self = shift;
   return $self->get_primary_key_value();

    }
    unless ( defined( &{$get} ) );
  *{$set} = sub {
   my $self = shift;
   $self->set_primary_key_value(@_);
    }
    unless ( defined( &{$set} ) );
 }
 if (    ( defined( $self->{SQL} ) )
      && ( defined( $self->{SQL}->{COLUMNS} ) ) )
 {

  *{get_column_names} = sub {
   my $self = shift;
   my %sql  = %{ $self->{SQL} };
   my @cols = @{ $sql{COLUMNS} };
   return @cols;

    }
    unless ( defined( &{get_column_names} ) );

  *{get_foreign_key_type} = sub {
   my $self      = shift;
   my $fk_column = shift;
   return unless ( defined( $self->{SQL}->{FOREIGNKEY} ) );
   my %fk = %{ $self->{SQL}->{FOREIGNKEY} };
   return unless ( defined( $fk{$fk_column} ) );
   my @return = keys( %{ $fk{$fk_column} } );
   return $return[0];
    }
    unless ( defined( &{get_foreign_key_type} ) );

  *{get_has_many_member_names} = sub {
   my $self          = shift;
   my %has_many_info = $self->get_has_many_info();
   return keys(%has_many_info);
    }
    unless ( defined( &{get_has_many_member_names} ) );

  *{get_many_to_many_member_names} = sub {
   my $self      = shift;
   my %many_info = $self->get_many_to_many_info();
   return keys(%many_info);
    }
    unless ( defined( &{get_many_to_many_member_names} ) );

  *{get_has_many_info} = sub {
   my $self = shift;
   return unless ( $self->{SQL}->{HASMANY} );

   my %has_many = %{ $self->{SQL}->{HASMANY} };
   my %return;
   foreach my $type ( keys(%has_many) )
   {
    my @list = @{ $has_many{$type} };
    for ( my $i = 0 ; $i <= $#list ; $i++ )
    {

     my %description = %{ $list[$i] };
     my ( $member, $fk_col ) = each %description;

     $return{$member} = $type;
    }
   }
   return %return;
    }
    unless ( defined( &{get_has_many_info} ) );
  *{get_many_to_many_info} = sub {
   my $self = shift;
   return unless ( $self->{SQL}->{MANYTOMANY} );
   my %many = %{ $self->{SQL}->{MANYTOMANY} };
   my %return;
   foreach my $type ( keys(%many) )
   {
    my @list = @{ $many{$type} };
    foreach my $many_description (@list)
    {
     my $member = $many_description->{member};
     $return{$member} = $type;
    }
   }
   return %return;
    }
    unless ( defined( &{get_many_to_many_info} ) );

  *{get_object_type} = sub {
   my $self = shift;
   return $self->{TYPE};

    }
    unless ( defined( &{get_object_type} ) );

  *{get_type_for_many_member} = sub {
   my $self        = shift;
   my $member_name = shift;

   my %has_many = $self->get_has_many_info();

   my %many_to_many = $self->get_many_to_many_info();

   my %many = ( %many_to_many, %has_many );

   return $many{$member_name}
     if ( $many{$member_name} );
    }
    unless ( defined( &{get_type_for_many_member} ) );

  *{get_member_for_column} = sub {
   my $self       = shift;
   my $column     = shift;
   my $short_name = undef;
   my $member     = undef;
   my $fktype     = undef;

   #$sql->{FOREIGNKEY}->{'TestObject1_ID'} = 'BFTG::DO::TestObject1';

   my %fk = ();
   %fk = %{ $self->{SQL}->{FOREIGNKEY} }
     if ( defined( $self->{SQL}->{FOREIGNKEY} ) );
   foreach my $key ( keys(%fk) )
   {

    if ( $column eq $key )
    {
     ( $type, $member ) = each( %{ $fk{$key} } );

    }
   }
   return $member;
    }
    unless ( defined( &{get_member_for_column} ) );
 }

 #
 # Generate accessors for each column field
 #

 my @columns = ();
 @columns = @{ $self->{SQL}->{COLUMNS} }
   if ( defined( $self->{SQL}->{COLUMNS} ) );
 foreach my $col (@columns)
 {
  my $get = "get_" . $col;
  my $set = "set_" . $col;

  *{$get} = sub {
   my $self = shift;
   return $self->{$col};

    }
    unless ( defined( &{$get} ) );
  *{$set} = sub {
   my $self = shift;
   $self->{$col} = shift;
    }
    unless ( defined( &{$set} ) );
 }

 # Generate the accessor methods for the fk relationship
 if (    ( defined( $self->{SQL} ) )
      && ( defined( $self->{SQL}->{FOREIGNKEY} ) ) )
 {
  my %foreign_key = %{ $self->{SQL}->{FOREIGNKEY} };
  foreach my $column ( keys(%foreign_key) )
  {
   my ( $object_name, $member_name ) =
     %{ $foreign_key{$column} };  #abreviated object name; the name after last::
   my $object_abr = $object_name;
   $object_abr =~ s/.*::(\w+)$/$1/;    #the name after last::
   my $get_method = $type . '::' . 'get_' . $member_name;
   my $set_method = $type . '::' . 'set_' . $member_name;

   # * denotes a method in perl symbol table
   *{$get_method} = sub {
    my $self = shift;

    my $fk_object;
    $fk_object = $object_name->new()->load( $self->{$column} )
      if ( $self->{$column} );

    return $fk_object;

     }
     unless ( defined( &{$get_method} ) );
   *{$set_method} = sub {
    my ( $self, $object ) = @_;

    if (    ( defined($object) )
         && ( defined( $object->get_primary_key_value() ) ) )
    {

     $self->{$column} = $object->get_primary_key_value();
    } elsif ( defined($object) )
    {
     carp "object of type $object_name must be saved prior to setting";
     $object->save;
     $self->{$column} = $object->get_primary_key_value();

    } else
    {    #passing undef removes relationship
     $self->{$column} = undef;
    }
     }
     unless ( defined( &{$set_method} ) );   #only make methods not already made
   use strict;

  }
 }

 #generate accessor methods for has Many
 if (    ( defined( $self->{SQL} ) )
      && ( defined( $self->{SQL}->{HASMANY} ) ) )
 {
  my %has_many = %{ $self->{SQL}->{HASMANY} };
  foreach my $object_name ( keys(%has_many) )
  {
   my @list = @{ $has_many{$object_name} };
   for ( my $i = 0 ; $i <= $#list ; $i++ )
   {
    my $object_abr = $object_name;
    $object_abr =~ s/.*::(\w+)$/$1/;    #the name after last::
    my ( $member, $column ) = %{ $has_many{$object_name}->[$i] };
    my $get_method    = $type . '::' . 'get_' . $member;
    my $set_method    = $type . '::' . 'set_' . $member;
    my $remove_method = $type . '::' . 'remove_from_' . $member;
    my $add_method    = $type . '::' . 'add_to_' . $member;

    *{$get_method} = sub {
     my $self = shift;

     unless (    ( defined( $self->{$member} ) )
              && ( scalar( @{ $self->{$member} } ) ) )
     {
      $self->_load_has_many( member => $member );
     }
     return @{ $self->{$member} };
      }
      unless ( defined( &{$get_method} ) ); #only make methods not already made;
    *{$set_method} = sub {
     my ( $self, $many_ref ) = @_;

     my @old_relationships = ();
     @old_relationships = @{ $self->{$member} }
       if ( defined( $self->{$member} ) );
     my $remove = 'remove_from_' . $member;
     foreach my $old (@old_relationships)
     {
      $self->$remove($old);

     }
     $self->{$member} = $many_ref;
      }
      unless ( defined( &{$set_method} ) );  #only make methods not already made
    *{$add_method} = sub {
     my $self   = shift;
     my $object = shift;

     my @list = @{ $self->{$member} };
     push( @list, $object );
     $self->{$member} = \@list;

      }
      unless ( defined( &{$add_method} ) );  #only make methods not already made
    *{$remove_method} = sub {
     my $self     = shift;
     my $object   = shift;
     my $abr_name = $self->{TYPE};
     $abr_name =~ s/.*::(\w+)$/$1/;
     my @list = @{ $self->{$member} };

     for ( my $i = 0 ; $i < scalar(@list) ; $i++ )
     {
      my $item = $list[$i];
      if ( $item->get_primary_key_value() == $object->get_primary_key_value() )
      {
       splice( @list, $i, $is_verbose );
       my $func = "set_" . $abr_name;
       $object->$func(undef);
       $object->save();
      }
     }
     $self->{$member} = \@list;
      }
      unless ( defined( &{$remove_method} ) )
      ;    #only make methods not already made
   }
  }
 }

 #set accessors for many to many relationships

 if (    ( defined( $self->{SQL} ) )
      && ( defined( $self->{SQL}->{MANYTOMANY} ) ) )
 {
  my %to_many = %{ $self->{SQL}->{MANYTOMANY} };
  foreach my $object_name ( keys(%to_many) )
  {
   my @list = @{ $to_many{$object_name} };

   for ( my $i = 0 ; $i <= $#list ; $i++ )
   {
    my $object_abr = $object_name;
    $object_abr =~ s/.*::(\w+)$/$1/;    #the name after last::
        # my ($member, $column) = %{ $has_many{$object_name} };
    my %rel        = %{ $to_many{$object_name}->[$i] };
    my $rel_table  = $rel{table};
    my $my_col     = $rel{my_column};
    my $rel_col    = $rel{relationship_col};
    my $member     = $rel{member};
    my $table_pkey = $rel{table_primary_key} || 'ID';

    my $get_method    = $type . '::' . 'get_' . $member;
    my $set_method    = $type . '::' . 'set_' . $member;
    my $remove_method = $type . '::' . 'remove_from_' . $member;
    my $add_method    = $type . '::' . 'add_to_' . $member;

    *{$get_method} = sub {
     my $self = shift;

     unless ( scalar( keys( %{ $self->{$member} } ) ) )
     {
      $self->_load_to_many( member => $member );
     }
     my @pkeys  = keys( %{ $self->{$member} } );
     my @return = ();
     foreach my $pkey (@pkeys)
     {
      my $obj = $object_name->new()->load($pkey);
      push( @return, $obj );
     }

     return @return;
      }
      unless ( defined( &{$get_method} ) ); #only make methods not already made;
    *{$set_method} = sub {
     my $self     = shift;
     my $many_ref = shift;
     my @objects  = @{$many_ref};
     return unless ( scalar(@objects) );
     my $object = $objects[0];
     my $dbh    = $DBConnection->get_DBH();

   # $dbh = $self->new()->{DBH} unless( (defined($dbh) ) && ( $dbh->{Active}) );
     my @list =
       @{ $self->{SQL}->{MANYTOMANY}->{ $object->get_object_type } };

     for ( my $i = 0 ; $i <= $#list ; $i++ )
     {
      my %rel =
        %{ $self->{SQL}->{MANYTOMANY}->{ $object->get_object_type }->[$i] };
      my $rel_table = $rel{table};
      my $my_col    = $rel{my_column};
      Zoe::DataObject::Logger::debug(
                            "Removing previous MANYTOMANY for " . $self->{TYPE},
                            $is_verbose );
      if ( $self->get_primary_key_value() )
      {
       my $delete_cmd =
         "delete from  $rel_table where $my_col = "
         . $self->get_primary_key_value();
       Zoe::DataObject::Logger::debug( $delete_cmd, $is_verbose );
       $dbh->do($delete_cmd);
      }
     }
     $self->{$member}->{ $object->get_primary_key_value } = [];
     foreach my $object (@objects)
     {
      $self->{$member}->{ $object->get_primary_key_value } = undef;
     }
      }
      unless ( defined( &{$set_method} ) );  #only make methods not already made
    *{$add_method} = sub {
     my $self   = shift;
     my $object = shift;
     $self->{$member}->{ $object->get_primary_key_value } = undef;
      }
      unless ( defined( &{$add_method} ) );  #only make methods not already made
    *{$remove_method} = sub {
     my $self     = shift;
     my $object   = shift;
     my $abr_name = $self->{TYPE};
     $abr_name =~ s/.*::(\w+)$/$1/;
     my %list = %{ $self->{$member} };
     delete( $list{ $object->get_primary_key_value() } );

     $self->_delete_to_many($object);
     $self->{$member} = \%list;
      }
      unless ( defined( &{$remove_method} ) )
      ;    #only make methods not already made
   }
  }
 }
 bless( $self, $type );
 return $self;
}
############################################
# Usage      : instance method
# Purpose    : Used to persist object, sets
#				the primary key value on
#				newly created instances
# Returns    : n/a
# Parameters : n/a
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
sub save
{
 my $self = shift;
 my %args = @_;
 my $force_insert = $args{force_insert} || 0;
 
 my $dbh  = $DBConnection->get_DBH();

 #my $dbh    = $self->{DBH};
 my %sql     = %{ $self->{SQL} };
 my @columns = $self->get_column_names();
 
 #print $self->{TYPE}. "\n\n\n";
# print Dumper @columns;

 #Build sql
 my $table_name = $sql{'TABLE'};
 my ( $cmd, @bind, %values, %where, );
 my $pkey_name   = $self->get_primary_key_name();
 my $sql_builder = $self->_get_sql_builder;

 Zoe::DataObject::Logger::debug( "Begin save: $table_name id: id",
                                 $is_verbose );
 if( ( $self->{$pkey_name} ) && (! $force_insert) )
 {
  #update
  Zoe::DataObject::Logger::debug( "Updating $table_name", $is_verbose );
  foreach my $column (@columns)
  {
   $values{$column} = $self->{$column};
  }
  $where{$pkey_name} = $self->get_primary_key_value;
  ( $cmd, @bind ) = $sql_builder->update( $table_name, \%values, \%where );
 } else
 {
  #insert
  Zoe::DataObject::Logger::debug( "Inserting $table_name", $is_verbose );
  foreach my $column (@columns)
  {
   $values{$column} = $self->{$column} if ( $self->{$column} );
  }
  ( $cmd, @bind ) = $sql_builder->insert( $table_name, \%values );
 }

 #execute sql
 Zoe::DataObject::Logger::debug( $cmd . "  :values " . join( ", ", @bind ),
                                 $is_verbose );
#print Dumper $self;                                 
#print  $cmd . "\n\n\n";
 my $sth = $dbh->prepare($cmd);
 $dbh->{RaiseError} = 1;

 #warning  if @bind contains undef

 $sth->execute(@bind);

 my $row_id = $dbh->last_insert_id( undef, undef, $table_name, undef );
 Zoe::DataObject::Logger::debug( "Saved $row_id", $is_verbose );

 #if insert set primary key value
 $self->set_primary_key_value($row_id)
   unless ( $self->get_primary_key_value );
 $sth->finish;

 #for each has many object, persist
 Zoe::DataObject::Logger::debug( "Saving has many collections for $table_name",
                                 $is_verbose );
 if ( $sql{HASMANY} )
 {
  my %has_many = %{ $sql{HASMANY} };
  foreach my $type ( keys(%has_many) )
  {

   my @list = @{ $has_many{$type} };

   for ( my $i = 0 ; $i <= $#list ; $i++ )
   {
    my %map = %{ $has_many{$type}->[$i] };
    my ( $member, $column ) = each(%map);
    eval {
     my @collection = ();
     @collection = @{ $self->{$member} }
       if ( ( @{ $self->{$member} } ) );
     foreach my $obj (@collection)
     {

      my $new_obj = $type->new($obj);
      #print "saving have many collections for " . $type ."\n\n\n";
      $new_obj->{$column} = $self->get_primary_key_value();
      $new_obj->save();
      Zoe::DataObject::Logger::debug( "$type ------- $member, ------, $column",
                                      $is_verbose );
     }

    };
   }
  }
 }

 $self->_save_to_many() if ( $sql{MANYTOMANY} );
 return $row_id;
}

# Usage      : static method
# Purpose    : static wrapper for load_all
# Returns    : array
# Parameters : n/a
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
sub find_all
{
 my $type = shift;
 return $type->new()->load_all(@_);
}

sub split_search_string
{
 my $self          = shift;
 my $search_string = shift;
 my @words         = split( /\s+/, $search_string );
 my @all_words;
 my $i       = 0;
 my $in_word = 0;
 my $word;

 foreach $word (@words)
 {
  if ( $word =~ m/^("|')/ )
  {
   $in_word = 1;
   $all_words[$i] = $word;

  } elsif ($in_word)
  {
   $all_words[$i] .= " $word";
  } elsif ( $word =~ /("|')$/ )
  {
   $all_words[$i] .= " $word";
   $in_word = 0;
   $i++;
  } else
  {
   $all_words[$i] = $word;
   $i++;
  }

 }

 return @all_words;
}

# Usage      : sinstace
# Purpose    : provides search ability on specified or all columns
# Returns    : array
# Parameters : n/a
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
sub search
{
 my $self    = shift;
 my %arg     = @_;
 my $order   = $arg{order} || [];
 my $limit   = $arg{limit};
 my $offset  = $arg{offset} || 0;
 my $where   = $arg{where} || {};
 my %sql     = %{ $self->{SQL} };
 my @columns = @{ $arg{columns} };

 @columns = $self->get_column_names() unless ( scalar(@columns) );

 my %where = %{$where};
 my @where;

 my $search_string = $arg{search};
 return $self->load_all(@_) unless ($search_string);
 my @all_words = $self->split_search_string($search_string);

 foreach my $column_name (@columns)
 {
  foreach my $search_value (@all_words)
  {
   push(
         @where,
         (
           $column_name => { 'like', '%' . $search_value . '%' }
         )
   );
  }
 }

 my $table_name = $sql{'TABLE'};
 Zoe::DataObject::Logger::debug( "Searching $table_name for $search_string",
                                 $is_verbose );

 my @clause = (
  -and => [
            $where,
            [
              -or => \@where,
            ],
  ],

 );
 my %search_param = (
  where  => \@clause,
  order  => $order,
  limit  => $limit,
  offset => $offset,

 );
 return $self->load_all(%search_param);
}

############################################
# Usage      : instance method
# Purpose    : Returns all instances of object type
# Returns    : array
# Parameters : n/a
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
sub load_all
{
 my $self = shift;
 my %arg  = @_;

 my $where  = $arg{where}  || {};
 my $order  = $arg{order}  || [];
 my $limit  = $arg{limit}  || 0;
 my $offset = $arg{offset} || 0;
 my $dbh    = $DBConnection->get_DBH();
 my %sql    = %{ $self->{SQL} };
 my @columns = $self->get_column_names();
 my @return;

 #Build sql
 my $table_name = ( $arg{tables} || $sql{'TABLE'} );

 my $prefix_table = $sql{'TABLE'};

 foreach my $column_name (@columns)
 {
  $column_name = $prefix_table . "." . $column_name . ' as ' . $column_name;
 }
 Zoe::DataObject::Logger::debug( "Loading All from $table_name", $is_verbose );
 my $sql_builder = $self->_get_sql_builder;

 my ( $cmd, @bind );

 if ($limit)
 {
  ( $cmd, @bind ) =
    $sql_builder->select(
                          -from     => $table_name,
                          -columns  => \@columns,
                          -where    => $where,
                          -limit    => $limit,
                          -offset   => $offset,
                          -order_by => $order,
    );
 } else
 {
  ( $cmd, @bind ) =
    $sql_builder->select(
                          -from     => $table_name,
                          -columns  => \@columns,
                          -where    => $where,
                          -order_by => $order,
    );
 }

 Zoe::DataObject::Logger::debug( "SQL:: $cmd", $is_verbose );
 my $sth = $dbh->prepare($cmd);
 $sth->execute(@bind);
 @return = $self->_load_from_result($sth);

 # print Dumper @return;

 return @return;
}

############################################
# Usage      : private
# Purpose    : load objects by foreign key value
# Returns    : Zoe::DataObject sub object
# Parameters : hash -
#				where - hash ref to be used as where clasue
#				object- DataOBject child object used to
#						determine the type of object to return
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
sub _load_fk
{
 my $self       = shift;
 my %arg        = @_;
 my %where      = %{ $arg{where} };
 my $fk_obj     = $arg{object};
 my $dbh        = $DBConnection->get_DBH();
 my %sql        = %{ $self->{SQL} };
 my @columns    = $self->get_column_names();
 my $table_name = $sql{'TABLE'};

 Zoe::DataObject::Logger::debug(
                 "Loading  from $table_name where " . join( "=", each(%where) ),
                 $is_verbose );
 my $sql_builder = $self->_get_sql_builder;
 my ( $cmd, @bind ) = $sql_builder->select( $table_name, \@columns, \%where );

 
 
 my $sth = $dbh->prepare($cmd);
 $sth->execute(@bind);
 my @return;

 while ( my $row = $sth->fetchrow_hashref() )
 {
  my $obj = $self->new();
  foreach my $col ( keys( %{$row} ) )
  {
   $obj->{$col} = $row->{$col};
  }
  if ( $obj->{SQL}->{HASMANY} )
  {

  }
  push( @return, $obj );
 }
 return @return;
}

############################################
# Usage      : private
# Purpose    : Save Rows to Many to Many junction table
# Returns    : n/a
# Parameters : n/a
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
sub _save_to_many
{
 my $self    = shift;
 my $dbh     = $DBConnection->get_DBH();
 my %sql     = %{ $self->{SQL} };
 my %to_many = %{ $sql{MANYTOMANY} };

 foreach my $object_name ( keys(%to_many) )
 {
  my (%values);
  my @list = @{ $to_many{$object_name} };
  for ( my $i = 0 ; $i <= $#list ; $i++ )
  {
   my %rel         = %{ $to_many{$object_name}->[$i] };
   my $rel_table   = $rel{table};
   my $my_col      = $rel{my_column};
   my $rel_col     = $rel{relationship_col};
   my $member      = $rel{member};
   my $table_pkey  = $rel{table_primary_key} || 'ID';
   my %rel_to_pkey = ();

   if ( $self->{$member} )
   {
    %rel_to_pkey = %{ $self->{$member} };
   }

   foreach my $rel_id ( keys(%rel_to_pkey) )
   {
    my $pkey = $rel_to_pkey{$rel_id};

    #create the relationship unless primary key exits
    #in relationship table
    unless ($pkey)
    {
     $values{$rel_col} = $rel_id;
     $values{$my_col}  = $self->get_primary_key_value;
     my ( $cmd, @bind ) = $sql_builder->insert( $rel_table, \%values );
     Zoe::DataObject::Logger::debug( "Saving MANYTOMANY for " . $self->{TYPE},
                                     $is_verbose );

     Zoe::DataObject::Logger::debug( $cmd, $is_verbose );
     my $sth = $dbh->prepare($cmd);
     $sth->execute(@bind);
     my $row_id = $dbh->last_insert_id( undef, undef, $rel_table, undef );
     $rel_to_pkey{$rel_id} = $row_id;
    }
   }
   $self->{$member} = \%rel_to_pkey;
  }
 }
 return 1;
}
############################################
# Usage      : private
# Purpose    : selects Rows from Many to Many junction table
#				that correspond to object
# Returns    : n/a
# Parameters : n/a
# Throws     : no exceptions
# Comments   : Stores many to many relationships in hash_ref that
#				maps the related objects primary key to the primary
#				key of the junction table
# See Also   : n/a
sub _load_to_many
{
 my $self          = shift;
 my %arg           = @_;
 my $search_member = $arg{member};
 my $dbh           = $DBConnection->get_DBH();
 my %sql           = %{ $self->{SQL} };
 return unless ( $sql{MANYTOMANY} );
 my %to_many = %{ $sql{MANYTOMANY} };
 foreach my $object_name ( keys(%to_many) )
 {

  my @list = @{ $to_many{$object_name} };

  for ( my $i = 0 ; $i <= $#list ; $i++ )
  {
   my %rel        = %{ $to_many{$object_name}->[$i] };
   my $rel_table  = $rel{table};
   my $my_col     = $rel{my_column};
   my $rel_col    = $rel{relationship_col};
   my $member     = $rel{member};
   my $table_pkey = $rel{table_primary_key} || 'ID';

   next unless ( $search_member eq $member );
   my %rel_to_id = ();

   my @columns = ( $rel_col, $table_pkey );
   my %where = ( $my_col => $self->get_primary_key_value() );
   my ( $cmd, @bind ) = $sql_builder->select( $rel_table, \@columns, \%where );

   Zoe::DataObject::Logger::debug( $cmd, $is_verbose );
   my $sth = $dbh->prepare($cmd);
   $sth->execute(@bind);
   while ( my @row = $sth->fetchrow_array() )
   {
    $rel_to_id{ $row[0] } = $row[1];
   }
   $self->{$member} = \%rel_to_id;
  }
 }
 return;
}
############################################
# Usage      : instance method
# Purpose    : Uses the objects primary key to search
#				for the object and returns it.  Used
#				to refresh object data
# Returns    : Zoe::DataObject sub object
# Parameters : n/a
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
sub reload
{
 my $self = shift;
 return $self->load( $self->get_primary_key_value() );
}

sub _get_sql_builder
{
 return $sql_builder;
}

############################################
# Usage      : static method
# Purpose    : static wrapper around load
# Returns    : Zoe::DataObject sub object
# Parameters : primary key of object to be selected
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
sub find
{
 my $type = shift;
 my $id   = shift;
 return $type->new()->load($id);
}
############################################
# Usage      : instance method
# Purpose    : Uses the objects primary key to search
#				for the object and returns it.
# Returns    : Zoe::DataObject sub object
# Parameters : primary key of object to be selected
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
sub load
{
 my $self = shift;
 my $key  = shift;
 return unless $key;

 my $dbh     = $DBConnection->get_DBH();
 my %sql     = %{ $self->{SQL} };
 my @columns = $self->get_column_names();
 my @return;

 my %where;
 $where{ $self->get_primary_key_name } = $key;

 #Build sql
 my $table_name = $sql{'TABLE'};
 Zoe::DataObject::Logger::debug(
                         "Loading  from $table_name where primary key is $key ",
                         $is_verbose );
 my $sql_builder = $self->_get_sql_builder;
 my ( $cmd, @bind ) = $sql_builder->select( $table_name, \@columns, \%where );
 my $sth = $dbh->prepare($cmd);
 $sth->execute(@bind);
 @return = $self->_load_from_result($sth);

 #load any MANYTOMANY relationships that exist
 #eval { $return[0]->_load_to_many() };
 return $return[0];
}

############################################
# Usage      : static method
# Purpose    : static wrapper around load_by
# Returns    : array of Zoe::DataObject sub objects
# Parameters : hash -
#				where - hash ref to be used as where clasue
# Throws     : no exceptions
# Comments   : none
# See Also   : load_by
sub find_by
{
 my $type = shift;

 return $type->new()->load_by(@_);

}

sub load_by
{
 my $self = shift;
 return $self->load_all(@_);
}

############################################
# Usage      : private
# Purpose    : builds objects from result sets
# Returns    : array of objects
# Parameters : statement handle,
#				object of type to be constructed
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
sub _load_from_result
{
 my $self = shift;
 my $sth  = shift;
 my $obj;
 $obj = $self unless shift;
 my %sql = %{ $obj->{SQL} };
 my @return;

 #print Dumper $sth;
 while ( my $row = $sth->fetchrow_hashref() )
 {
  my $obj = $self->new();
  foreach my $col ( keys( %{$row} ) )
  {
   $obj->{$col} = $row->{$col};
  }
  if ( $obj->{SQL}->{HASMANY} )
  {

  }

  #print Dumper $obj;

  push( @return, $obj );
 }
 return @return;
}

sub _load_has_many
{
 my $self = shift;
 my %arg  = @_;

 my $obj           = $self;
 my $search_member = $arg{member};

 my %obj_sql  = %{ $obj->{SQL} };
 my %has_many = %{ $obj_sql{HASMANY} };
 Zoe::DataObject::Logger::debug( 'Loading HASMANY for ' . $obj->{TYPE},
                                 $is_verbose );
 foreach my $type ( keys(%has_many) )
 {
  my @list = @{ $has_many{$type} };

  for ( my $i = 0 ; $i <= $#list ; $i++ )
  {
   my %map = %{ $has_many{$type}->[$i] };
   my ( $member, $column ) = each(%map);

   next unless ( $search_member eq $member );
   my $child = $type->new();
   my $my_id = ( $obj->get_primary_key_value || 0 );
   my @children = $child->_load_fk( where  => { $column => $my_id },
                                    object => $obj );
   $obj->{$member} = \@children;
  }
 }
 return;
}

############################################
# Usage      : private??
# Purpose    : executes query
# Returns    : array of objects built by query
# Parameters : query,
#				array_ref - values
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
sub _execute
{
 my $self  = shift;
 my $query = shift;
 my $val   = shift;
 my $dbh   = $DBConnection->get_DBH();

 my $sth = $dbh->prepare($query) or confess "$!";

 #my @values 			= ($env);
 Zoe::DataObject::Logger::debug( $query, $is_verbose );
 if ($val)
 {
  $sth->execute( @{$val} );
 } else
 {
  $sth->execute();
 }

 return $self->_load_from_result($sth);
}

1;
__DATA__

=head1 NAME

Zoe::DataObject - Relational mapper



=head1 SYNOPSIS

	#Define objects to Map;
		
	package TestObject1;
	use Zoe::DataObject;
	use parent qw( Zoe::DataObject );


	sub new {

		#table definitions

		#set table definitions
		my $sql = {};
		
		#set the table name
		$sql->{TABLE} = 'TestObject1';
		
		#set the table definitions
		@{ $sql->{COLUMNS} } = qw(name );

		#define the primary key
		$sql->{PRIMARYKEY} = qq/ID/;

		
		#define HASMANY releationships
		#rel type        #column         #object type
		$sql->{HASMANY}->{TestObject2} =[{TestObject2_LIST => 'TestObject1_ID'} ];

		my $type = shift;
		my $self = __PACKAGE__->SUPER::spawn( @_, SQL => $sql );

		return bless $self;

	}
	1;

	package TestObject2;

	use Zoe::DataObject;
	use parent qw( Zoe::DataObject);


	sub new {
		#set table definitions
		my $sql = {};

		#set the table name
		$sql->{TABLE} = 'TestObject2';

		#set the table definitions
		@{ $sql->{COLUMNS} } = qw(name TestObject1_ID);

		#define the primary key
		$sql->{PRIMARYKEY} = qq/ID/;

		#define foreign keys
		#rel type        #column         #object type
		$sql->{FOREIGNKEY}->{TestObject1_ID} = 'TestObject1';

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

	package TestObject3;
	 
	use Zoe::DataObject;
	use parent qw( Zoe::DataObject);

	sub new {
		#set table definitions
		my $sql = {};

		#set the table name
		$sql->{TABLE} = 'TestObject3';

		#set the table definitions
		@{ $sql->{COLUMNS} } = qw(name);

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

#....later on...
	use TestObject1;
	use TestObject2;
	use TestObject3;

	#creates new empty instance
	my $to1	 = TestObject1->new();	
	$to1->save();

	#creates new instance with values populated via hash refference
	my $to2	 = TestObject2->new(
            {
			name => 'testobject2', 
			TestObject1 => $to1
			}
		);
	#creates new instance with values populated via hash 
	my $to3	= TestObject3->new(
		name => 'testobject3'
	);

	#save new entry or update existing
	$to1->save();
	$to2->save();
	$to3->save();

	#for every object member corresponding accessor methods are generate
	$to->set_name('testobject1');
	my $name 	= $to->get_name();
	$to->save();

	#return list of matching objects
	
	my %where = ('beer' => 'free');

	my @testobject1s	= TestObject1->find_by(\%where);

	#find all instances of object type
	my @testobject2s	= TestObject2->find_all($column_name, $column_value);

	#automatic accessor methods for has many and many to many relationships
	#for many to many this is determined by the member field
	#for has many it is the key of the hash ref assgined to the object type
	#key of the HASMANY hash ref
	$to1->set_TestObject1_LIST;

	my @testobject2s = $to1->set_TestObject1_LIST;

	#delete an object
	$to1->delete();
	
=head1 DESCRIPTION

This is an OO Relational mapper.  Objects  subclass Zoe::DataObject, define colums
and the various relationships, (has many, many to many, foreign key), and passes the configuration
information to the Zoe::DataObject->spawn or Zoe::DataObject->new

Zoe::DataObject provides a number of methods that can be used by child objects to save, delete, 
or find  an object, as well as utility methods that provide details about the ojbect and 
its underlying tables.  

Zoe::DataObject is SQL dialiect omnostic; all SQL is generated via SQL::Abstract::More.  

=head1 CONFIGURATION AND ENVIRONMENT

By default Zoe::DataObject looks for a configuration file named db.yml in ../../config/, (it assumes that 
is installed in the lib directory of the application).  The config file location can also be passed to the 
new or spawn method via the hash parameter DBCONFIGFILE

The configuration can have muliple entries corresponding to each environment.  An example db.yml file is shown below

	#sqlite3
	database:
	  development:
	    type: sqlite
	    dbfile: /home/joeblow/testobjects.db

	#mysql
	  testing:
	    type: mysql
	    dbname: testobjectdb
	    host: dev01.mycompany.com
	    port: 3306
	    dbuser: testobject
	    dbpassword: t3$t@123ABC



=head1 SUBROUTINES/METHODS



=head2  spawn

Calls Zoe::DataObject->new and passes the parameters; useful for objects with muliple parents:
unabiguates new ...(which parent constructer is called?).

	use parent qw( Zoe::DataObject);
	my $type = shift;
	my $self = __PACKAGE__->SUPER::spawn( @_, SQL => $sql );
	


=head2  new

Creates a new instance. Looks for the SQL argument to determine child object details.  This argument is a hash which can 
the following keys.


     TABLE      - mandatory; specifies the underlying table
         $sql->{TABLE} = 'TestObject1';
     COLUMNS    - mandatory; lists the tables' columns
        @{ $sql->{COLUMNS} } = qw(ID name );
     PRIMARYKEY - mandatory; specifies the tables primary key.  
        $sql->{PRIMARYKEY} = qq/ID/;
     FOREIGNKEY - defines foreign key relationship between two objects
        $sql->{FOREIGNKEY}->{'TestObject1_ID'}              # foreign key column
                          ->{'BFTG::DO::TestObject1'}       # foreign key types
                          = 'TestObject1';                  # name of member
    MANYTOMANY - defines many to many relationships
        my $many_description = {
            table            => 'TestObject2XTestObject3',
            my_column        => 'TestObject2_ID',
            relationship_col => 'TestObject3_ID',
            member           => 'TestObject3_LIST',
            primary_key      => 'ID',

        };
        push(
                @{ $sql->{MANYTOMANY}->{'BFTG::DO::TestObject3'}}, #many type
                $many_description 
            );
    HASMANY - defines one to many relationship_col
    push(
            @{$sql->{HASMANY}->{'BFTG::DO::TestObject2'} },     #many object type 
                {
                    'TestObject2_LIST' =>                       #member
                    'TestObject1_ID'                            #foreign key column in child table
                 }
       );
     
Also looks for DBCONFIGFILE argument for the database configuration file.  If it is not found, it attempts 
to read db.yml from the ../../config directory 

	use parent qw( Zoe::DataObject);
	my $type = shift;
	my $self = __PACKAGE__->SUPER::new @_, SQL => $sql, DBCONFIG='~/db.yml' );

=head2  save

Saves object.  For objects which have has many and many to many relationships, it propogates
the saves (probably should be optional)

=head2  delete

deletes object.  For objects which have has many and many to many relationships, it propogates
the delete (probably should be optional)

=head2  reload

Reloads object data from the database

	$object	= $object->reload

=head2  get_database_handle 

Returns the database handle

=head2  find( $pkey )

Short cut static method; Calls Zoe::DataObject->new()->load() and passess the arguments

=head2  find_all ( where=>\%where, order=>\@order, limit => $limit, offset => $offset )

Short cut static method; Calls Zoe::DataObject->new()->load_all() and passess the arguments

=head2  find_by( where=>\%where, order=>\@order, limit => $limit, offset => $offsete )

Short cut static method; Calls Zoe::DataObject->new()->load_by() and passess the arguments

=head2  load( $pkey )

Finds object by primary key

=head2  load_all ( where=>\%where, order=>\@order, limit => $limit, offset => $offset )

Returns array containing all instances of object type. 
%where is a has contain column names to values
@order is a list of column names to sort by; prepending a - (minus) sign specifies reverse order
$limit limits the number  of rows returned
$offset specifies the offset for the underlying sql statement

=head2  load_by ( where=>\%where, order=>\@order, limit => $limit, offset => $offset ))

wrapper arround load_all

=head2  get_object_type

Returns the objects'' class

=head2  get_type_for_many_member

Accepts name of member variable associated with a has many or many to many relationship and 
returns its type.  

=head2  get_member_for_column( $column_name )

Accepts a column name and returns the name of the corresponding instance variable.  Used 
To determine the name of the member that holds the foreign key object

=head2  get_many_to_many_member_names

Returns array of member variable names that coresspond to many to many relationship

=head2  get_many_to_many_info

Returns hash of member variable names to corresponding object type from many to many relationships

=head2  get_has_many_member_names

Returns array of member variable names that coresspond to has many relationship

=head2  get_has_many_info

Returns hash of member variable names to corresponding object type from has many relationships

=head2  get_column_names

Returns the column names of the underlying table 

=head2  get_foreign_key_type( $member_variable_name )

Accepts member variable name and returns the type for foreign key members

=head2  set_primary_key_value( $pkey_value)

Mutator method for member defined as primary key 

=head2  get_primary_key_value

Accessor method for member defined as primary key 

=head2  get_primary_key_name

Returns the name of the member/column defined as the primary key 

=head2  set_<member name>( $value )

For every column and member defined as a has many or many to many relationship a 
mutator method is created

=head2  get_<member name>

For every column and member defined as a has many or many to many relationship a 
accessor method is created

=head2  add_to_<member_name>( $object )

For every member that is defined as a has many or many to many member; an add_to_<MEMBER_NAME>
method is created

=head2  remove_from_<member_name>($object)

For every member that is defined as a has many or many to many member; an remove_from_<MEMBER_NAME>
method is created which removes the specified object from the list

	
=head1 Author
	dinnibartholomew@gmail.com
	

