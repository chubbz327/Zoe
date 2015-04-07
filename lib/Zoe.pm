package Zoe;
use 5.010;
use strict;
use warnings;
use Mojo::Base 'Mojolicious';
use File::Basename 'dirname';
use File::Spec::Functions 'catdir';
use DateTime;
use DateTime::Format::DBI;
use Data::Dumper;

#use YAML::Tiny;
use FindBin;
use Path::Class;    #non os specific file and dir access
use File::Copy;
use File::Path qw(make_path remove_tree);
use SQL::Abstract;
use SQL::Translator;
use File::Touch;
use File::Copy::Recursive qw(dircopy);
use File::NCopy;
use File::Slurp;
use Lingua::EN::Inflect qw ( PL);
use String::CamelCase qw(decamelize);
use Log::Message::Simple qw[msg error debug
  carp croak cluck confess];
use Mojo::Asset::File;
use Hash::Merge;
use Zoe::Runtime;
use Zoe::DO::Role;
use Zoe::DO::User;
use YAML::XS;

use Mojo::Template;

my (
    $application_config_file, #yaml config file for app
    $application_description, #applicaiton description read from yml
    $application_db_yml,      # application db.yml location
    $application_name,        #name of the application
    $application_location,    #directory where app is stored
    $is_verbose,              #logging
    $do_replace_existing,     #boolean - should existing controllers be replaced
    $no_ddl,                  #should ddl be executed command arg
    @objects_meta,            #ObjectMeta objects for each parsed
    $application_home,        #parent dir
    $ZOE_HOME,                #home directory in which Zoe is installed
    $ZOE_FILES,               # zoe template files
    $runtime,                 #application runtime,
    $application_runtime_type,    #generated class that represents app runtime
    $mojolicious_template,
    @import_files,
);

BEGIN
{
    unshift @INC, "" . dir( catdir( dirname(__FILE__), 'Zoe' ) );
}
use Zoe::ObjectMeta;
use Zoe::DataObject;

# This method will run once at server start
sub startup
{
    my $self = shift;
    $ENV{MOJO_LISTEN} = 'http://*:3456';

    # Switch to installable home directory
    $self->home->parse( catdir( dirname(__FILE__), 'Zoe' ) );

    # Switch to installable "public" directory
    $self->static->paths->[0] = $self->home->rel_dir('public');

    # Switch to installable "templates" directory
    $self->renderer->paths->[0] = $self->home->rel_dir('templates');

    # Documentation browser under "/perldoc"
    $self->plugin('PODRenderer');

    # Router
    my $r = $self->routes;

    # Normal route to controller
    $r->get('/')->to(
        cb => sub {
            my $self = shift;
            $self->render( message => '', template => 'upload' );
        }
    );
    $r->get('/tutorial')->to(
        cb => sub {
            my $self = shift;
            $self->render( template => 'tutorial' );
        }
    );
    $r->post('/upload')->to(
        cb => sub {
            my $self          = shift;
            my $uploaded_file = $self->param('file');
            my $filename      = $uploaded_file->filename;
            my $tmp_dir       = dir( $ZOE_FILES, 'tmp' );
            my $file_path     = file( $tmp_dir, $filename );
            $uploaded_file->move_to($file_path);
            Zoe->new()->generate_application(
                                      application_config_file => ["$file_path"],
                                      is_verbose              => 1 );
            my $message =
"$application_name has been succssfully created in $application_home";
            $self->render( message => $message, template => 'upload' );
        }
    );
}
############################################
# Usage      : public
# Purpose    : Method used to coordinate application generation
# Returns    : n/a
# Parameters : n/a
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
sub generate_application
{
    my $self = shift;
    $self->zoe_init(@_);
    $self->generate_mojo_app();

    my $db_file_content = {};
    $db_file_content->{database} = $application_description->[0]->{database};
    my $db_type = $db_file_content->{database}->{type};
    if ( $db_type =~ /sqlite/ )
    {
        my $db_file = $db_file_content->{database}->{dbfile};
        my $toucher = File::Touch->new();
        $toucher->touch($db_file);
    }

    my $import_dir  = dir( $application_location, '..', 'yaml', 'import' );
    make_path( "" . $import_dir) unless ( -d $import_dir );
    
    my $runtime_dir  = dir( $application_location, '..', 'yaml', 'runtime' );
    make_path( "" . $runtime_dir) unless ( -d $runtime_dir );
    
    $self->generate_mvc();

    #create runtime.yml
    #create config directory under the mojo app location
    my $dir = dir( $application_location, 'config' );

    #make config dir under the mojo app
    make_path( "" . $dir ) unless ( -d $dir );
    

    

    my $runtime_yml = file( $application_location, 'config', "runtime.yml" );
    if ( -e $runtime_yml )
    {
        msg( "Overiting existing $runtime_yml", $is_verbose );
    } else
    {
        msg( "Creating $runtime_yml", $is_verbose );
    }

    #dinni
     local $YAML::SortKeys = 0;
    my $runtime_string = YAML::XS::DumpFile( $runtime_yml, $runtime )
      or die "$!";

}

sub _import_files
{
    my %import_hash;
    my $time = time();
    return unless (@import_files);
    foreach my $file (@import_files)
    {
        my $config = YAML::XS::LoadFile($file)
          or croak " YAML Parse error in $file" . $!;

        my $tmp_ref;
        $tmp_ref =
          Hash::Merge->new('RETAINMENT_PRECEDENT')
          ->merge( $config, \%import_hash )
          if (%import_hash);
        if ($tmp_ref)
        {
            %import_hash = %$tmp_ref;
        } else
        {

            %import_hash = %$config;
        }

    }
    foreach my $type ( keys(%import_hash) )
    {
        print $type . "TYPE \n";
        my @all_data = @{ $import_hash{$type} };
        foreach my $data (@all_data)
        {
            my $object = $type->new( %{$data} );
            $object->save( force_insert => 1 );
        }
    }
    
    my $file_name = 'backup_' . 'all_models_' . $time . '.yaml';
    my $save_file =
      file( $application_location, '..', 'yaml', 'import', $file_name );
     local $YAML::SortKeys = 0;
    YAML::XS::DumpFile( $save_file, \%import_hash )
      or croak "could not save $file_name";
}
############################################
# Usage      : private
# Purpose    : Read arguments and set values
#				of global variables
# Returns    : n/a
# Parameters : n/a
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
sub zoe_init
{
    my $self = shift;
    my %arg  = @_;
    my @application_files;
    my %tmp_hash;
    $ZOE_HOME            = dir( catdir( dirname(__FILE__) ) );
    $ZOE_FILES           = dir( $ZOE_HOME, 'Zoe', 'Zoe_files' );
    $no_ddl              = $arg{no_ddl};
    $do_replace_existing = $arg{replace};
    $is_verbose          = $arg{is_verbose};
    if (defined($arg{'import'})){
        @import_files        = @{ $arg{'import'} };
    }

    #$application_description_string = $arg{application_description};
    @application_files = @{ $arg{application_config_file} };
    unless ($application_description)
    {
        $application_description = [];
        foreach my $file (@application_files)
        {
            my $config = YAML::XS::LoadFile($file)
              or croak " YAML Parse error in $application_config_file" . $!;

            my $tmp_ref;
            $tmp_ref =
              Hash::Merge->new('RETAINMENT_PRECEDENT')
              ->merge( $config, \%tmp_hash )
              if (%tmp_hash);
            if ($tmp_ref)
            {
                %tmp_hash = %$tmp_ref;
            } else
            {

                %tmp_hash = %$config;
            }

        }
    }
    unless ( $tmp_hash{'authorization'} )
    {
        my $file = file( $ZOE_FILES, 'yaml', 'auth.yml' );
        my $config = YAML::XS::LoadFile($file)
          or croak " YAML Parse error in auth.yml" . $!;
        my $tmp_ref =
          Hash::Merge->new('RETAINMENT_PRECEDENT')
          ->merge( $config, \%tmp_hash );
        %tmp_hash = %$tmp_ref;
    }

  #add runtime
  #    my $file = file( $ZOE_FILES, 'yaml', 'runtime_model.yml' );
  #    my $config = YAML::XS::LoadFile($file)
  #      or croak " YAML Parse error in runtime_model.yml" . $!;
  #    my $tmp_ref =
  #      Hash::Merge->new('RETAINMENT_PRECEDENT')->merge( $config, \%tmp_hash );
  #    %tmp_hash = %$tmp_ref;

    $application_description->[0] = \%tmp_hash;

    #Set application name
    $application_name =
      $application_description->[0]->{serverstartup}->{application_name};
    my $application_name_LC = $application_name;
    $application_name_LC = lc( decamelize($application_name) );

    #application name replace spaces with dashes
    $application_name =~ s/\s/_/gmx;

    #Set application location
    $application_home =
      $application_description->[0]->{serverstartup}->{location};
    if ( -d $application_description->[0]->{serverstartup}->{location} )
    {
        msg(
             'Path: '
               . $application_description->[0]->{serverstartup}->{location}
               . ': exists',
             $is_verbose
        );
    } else
    {
        make_path( $application_description->[0]->{location} );
        msg(
             'Path: '
               . $application_description->[0]->{serverstartup}->{location}
               . ': created',
             $is_verbose
        );
    }
    $application_location =
        $application_description->[0]->{serverstartup}->{location} . '/'
      . $application_name_LC;
    msg( "Generating $application_name $application_location", 1 );

    $runtime = $application_description->[0];

    # create mojolicious template
    $mojolicious_template = Mojo::Template->new;
    return;
}
############################################
# Usage      : private
# Purpose    : Writes the tests file generated models and web app
# Returns    : n/a
# Parameters : n/a
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
sub _write_tests
{
    my ($objects_ref) = shift;
    my $url_prefix = shift || '';

    my $test_use_list_string  = '';
    my $set_foreign_key_code  = '';
    my $create_new            = '';
    my $save_test_code        = '';
    my $update_test_code      = '';
    my $find_by_pk_test_code  = '';
    my $find_by_col_test_code = '';
    my $test_show             = '';
    my $test_post             = '';
    my $test_dir              = dir( $application_location, 't' );
    my $do                    = Zoe::DataObject->new( runtime => $runtime );
    make_path("$test_dir")
      or croak "Could not create $test_dir"
      unless ( -d "$test_dir" );
    my $test_file = file( $application_location, 't', '00.crud.t' );
    my $test_statements = '';
    _set_object_meta($objects_ref);
    my $test_code = read_file( file( $ZOE_FILES, 'templates', '00.crud.tpl' ) );

    #my $test_number = scalar (@objects_meta);
    foreach my $object (@objects_meta)
    {
        my $object_name = $object->{object};

        #do not generate tests for zoe runtime objects
        next if ( $object_name =~ /Zoe\:\:Runtime/ );
        next if ( $object_name =~ /Zoe\:\:DO/ );

        #do not generate tests for authentication objects

        my $role_regex =
          $application_description->[0]->{authorization}->{config}
          ->{data_object}->{role_object} || 0;

#my $user_regex = $application_description->[0]->{authorization}->{config}->{data_object}->{user_object} || 0;
        $role_regex =~ s/\:/\\:/g;

        #$user_regex =~ s/\:/\\:/g;
        #next if ( $object_name =~ /$role_regex/ );
        #next if ( $object_name =~ /$user_regex/ );

        my $object_name_short = $object_name;
        my $web_updated_code  = '';
        $object_name_short =~ s/\:\:/_/gmx;

        my $object_route = $object->{object};
        $object_route =~ s/\:\:/\//g;
        $object_route = lc($object_route);

        $test_use_list_string .= " '$object_name',\n";
        my $variable_name = "\$v$object_name_short";
        $save_test_code .= qq^$variable_name->save;\n^;
        $save_test_code .=
qq^ ok($variable_name->get_primary_key_value, '$object_name save');\n^;
        $create_new = qq^ my $variable_name = $object_name->new (^;

        foreach my $column ( @{ $object->{columns} } )
        {
            my $member = $column->{member} || $column->{name};

            #unless primary key or foreign key value
            unless (    ( defined( $column->{primary_key} ) )
                     || ( defined( $column->{foreign_key} ) ) )
            {
                my $random_string = rand;
                if (    ( $column->{type} =~ /date.*/i )
                     || ( $column->{type} =~ /time.*/i ) )
                {
                    my $db_parser =
                      DateTime::Format::DBI->new( $do->get_database_handle() );
                    my $dt = DateTime::now();
                    $random_string = $db_parser->format_datetime($dt);
                }
                my $column_name     = $column->{name};
                my $variable_string = "\t$column_name => '$random_string', \n";
                $create_new .= $variable_string;
            } elsif ( defined( $column->{foreign_key} ) )
            {

                # $member      = $column->{member};
                my $method        = 'set_' . $member;
                my $fk_type       = $column->{foreign_key};
                my $fk_short_name = $fk_type;

                #$fk_short_name =~ s/.*\:\:(\w+)$/$1/gmx;
                $fk_short_name =~ s/\:\:/_/gmx;

                my $fk_variable_name = '$v' . $fk_short_name;
                $set_foreign_key_code .=
                  qq^$variable_name->$method($fk_variable_name); ^;
                $test_statements .=
qq^#check foreign_key relationship between $object_name and $fk_type\n^;
                $test_statements .=
qq^ok( $variable_name->get_$member()->get_primary_key_value == \n\t$fk_variable_name->get_primary_key_value,\n^;
                $test_statements .=
qq^'foreign_key relationship between $object_name and $fk_type save'); ^;

                my $column_name     = $column->{name};
                my $variable_string = "\t$column_name => 1, \n";
                $create_new .= $variable_string;
            }

            #write test code for object updates
            #the to_string variable will be used for update and find tests
            if ( defined( $column->{to_string} ) )
            {
                my $random_string2 = rand() . "_UPDATED";
                $update_test_code .=
                    qq^$variable_name->set_$member('$random_string2');\n ^
                  . qq^$variable_name->save();\n^
                  . qq^$variable_name = $variable_name->reload();\n^
                  . qq^ok($variable_name->get_$member eq '$random_string2', \n^
                  . qq^ '$object_name updated');\n^
                  . qq^\n#Find $object_name by $member\n ^
                  . qq^\$where ={ $member => '$random_string2'};\n^
                  . qq^ \@tmp_list = ($object_name->find_by(where => \$where));\n^
                  . q^$v_tmp = $tmp_list[$#tmp_list];^
                  . qq^\nok(\$v_tmp->get_primary_key_value == $variable_name->get_primary_key_value, \n\t^
                  . qq^'Find $object_name by $member ');\n^;
            }
        }
        $create_new .= qq^);\n^;

        #find by primary key code
        $find_by_pk_test_code .=
qq^\$v_tmp = $object_name->find($variable_name->get_primary_key_value);\n^
          . qq^ok(\$v_tmp->get_primary_key_value == $variable_name->get_primary_key_value, \n\t^
          . qq^'Find $object_name by primary_key ');\n^
          . qq^$variable_name = \$v_tmp ;^;
        $test_code =~ s/(\#__OBJECTCREATE__)/$1\n$create_new/gmx;
        my $object_url_base = "/" . $url_prefix . $object_route;
        my $show_url        = $object_url_base . '/';
        my $show_all_url    = $object_url_base;
        my $post_url        = $object_url_base . '/';
        $test_show .=
          qq^\$t->get_ok('$show_url' . $variable_name->get_primary_key_value)\n^
          . qq^      ->status_is(200,"Found $object_name with pkey of " . $variable_name->get_primary_key_value . "via http get")\n;^
          . qq^\$t->get_ok('$show_all_url')->status_is(200, \n^
          . qq^          "Found all $object_name via http get")\n;^;
        $test_post .=
qq^ post_data('$post_url' . $variable_name->get_primary_key_value, $variable_name);\n^;
    }
    $test_code =~ s/\#__TESTUSELIST__/$test_use_list_string/gmx;
    $test_code =~ s/\#__SETFOREIGNKEYCODE__/$set_foreign_key_code/gmx;
    $test_code =~ s/\#__TESTSTATEMENTS__/$test_statements/gmx;
    $test_code =~ s/\#__SAVETESTCODE__/$save_test_code/gmx;
    $test_code =~ s/\#__FINDBYPK__/$find_by_pk_test_code/gmx;
    $test_code =~ s/\#__UPDATETESTCODE__/$update_test_code/gmx;
    $test_code =~ s/\#__APPLICATIONNAME__/$application_name/gmx;
    $test_code =~ s/\#__TESTSHOW__/$test_show/gmx;
    $test_code =~ s/\#__TESTPOST__/$test_post/gmx;
    $test_code =~ s/\#__URLPREFIX__/$url_prefix/gmx;
    write_file( "$test_file", $test_code ) or croak "Could not open $test_file";
    return;
}
############################################
# Usage      : private
# Purpose    : Copies fragments used by Zoe::Helpers
# Returns    : n/a
# Parameters : n/a
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
sub _copy_fragments
{
    my $from = dir( $ZOE_FILES,            'templates', 'fragments' );
    my $to   = dir( $application_location, 'templates', 'fragments' );
    
    if($do_replace_existing ){
        remove_tree($to);
    }
    
    dircopy( "$from", "$to", )
      or die "Could not copy fragments directory: $from $to\n$!";
      ##unless ($to);

}
############################################
# Usage      : private
# Purpose    : Writes the layout file for
#		application scaffold
# Returns    : n/a
# Parameters : n/a
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
sub _write_layout
{
    
    my $side_bar_out =
      file( $application_location, 'templates', 'sidebar.html.ep' );
    my $objects_ref = shift;
    my $url_prefix  = shift;
    $url_prefix = '' unless ($url_prefix);

    #copy layout file
    my $from = dir( $ZOE_FILES, 'templates', 'layouts' );
    my $to =  dir ( $application_location, 'templates', 'layouts',);

    dircopy( $from, $to )  or croak "Could not copy $from to $to :$!\n";
    
 
    my $side_bar_tpl =
      read_file( file( $ZOE_FILES, 'templates', 'side_bar.tpl' ) )
      or croak "could not read side_bar.tpl ";

    my $side_bar =
      $mojolicious_template->render( $side_bar_tpl, $objects_ref, $url_prefix );

 

    # if paypal is enabled add the paypal links to the side_bar_file
    if ( $application_description->[0]->{paypal} )
    {
        $side_bar .=
"<li><a href='/__PAYPALTRANSACTION__'><i class='icon-chevron-right'></i> Paypal Transaction</a></li>";
    }

    #$layout_content =~ s/\#__SIDEBAR__/$side_bar/gmx;
    write_file( $side_bar_out, $side_bar )
      or croak "Could not write file $side_bar_out: $!";
   
    return;
}
############################################
# Usage      : private
# Purpose    : Runs the mojo command and copies
#		javascript and helpers
# Returns    : n/a
# Parameters : n/a
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
sub generate_mojo_app
{
    msg( "Running: mojo generate app $application_name:\n " . "MOJO output: ",
         $is_verbose );
    my $mojo_message = `mojo generate app $application_name`;
    msg( $mojo_message, $is_verbose );

    ##copy application_directory to temp dirctory
    ## this is in the event that the script is run from install path
    my $tmp_dir_name          = time();
    my $application_directory = decamelize($application_name);

    dircopy( $application_directory, $tmp_dir_name )
      or croak "Could not create temporary directory $tmp_dir_name:$!\n";

    remove_tree($application_directory)
      or croak
      "Could not remove temporary directory $application_directory:$!\n";

    dircopy( $tmp_dir_name, "$application_location" )
      or croak
      "Could not move: $application_directory  $application_location\n$!";

    remove_tree($tmp_dir_name)
      or croak "Could not remove temporary directory $tmp_dir_name:$!\n";

    my $from_asset = dir( $ZOE_FILES,            'public' );
    my $to_asset   = dir( $application_location, 'public' );

    if($do_replace_existing ){
        remove_tree($to_asset);
    }


    dircopy( "" . $from_asset, "" . $to_asset )
      or croak "could not copy $from_asset to $to_asset: $!";
      #unless (-d $to_asset);
      
      
    msg( "Copied $from_asset\n\tto $to_asset", $is_verbose );

    #make applicaiton lib directory
    my $application_lib =
      dir( $application_location, 'lib', $application_name );
    make_path("$application_lib")
      or croak "Could not make $application_lib"
      unless ( -d "$application_lib" );
    msg( "Created $application_lib", $is_verbose );

    #create upload directory
    my $upload_dir = dir( $application_location, 'public', 'upload' );
    if ( -d "$upload_dir" )
    {
        msg( "$upload_dir exists", $is_verbose );
    } else
    {
        make_path("$upload_dir")
          or croak "Could not create upload path $upload_dir";
        msg( "Created $upload_dir", $is_verbose );
    }
    return;
}

sub _get_object_meta
{
    my $object_name = shift;
    foreach my $object_meta (@objects_meta)
    {
        return $object_meta if ( $object_meta->{object} eq $object_name );
    }
}

sub _set_object_meta
{
    my $objects_ref = shift;
    foreach my $object ( @{$objects_ref} )
    {
        my $object_meta = Zoe::ObjectMeta->new();
        $object_meta->{object}  = $object->{object};
        $object_meta->{columns} = $object->{columns};
        foreach my $column ( @{ $object->{columns} } )
        {
            if ( defined( $column->{primary_key} )
                 && ( $column->{primary_key} ) )
            {

                #set meta info for primary_key
                $object_meta->{primary_key} = $column->{name};
            }

            #foreignkey setup
            if ( defined( $column->{foreign_key} ) )
            {

                #add info to meta object; increment level
                $object_meta->{foreign_key_feilds}->{ $column->{name} } =
                  $column->{foreign_key};
                $object_meta->{num_foreign_keys}++;
            }
            if ( defined( $column->{to_string} ) )
            {
                $object_meta->{to_string_member} = $column->{name};
            }
        }
        if ( defined( $object->{has_many} ) )
        {
            foreach my $has_many ( @{ $object->{has_many} } )
            {
                $object_meta->{has_many}->{ $has_many->{object} } =
                  $has_many->{member};
            }
        }
        ##################################################
        # set many to many relationships
        ##################################################
        if ( defined( $object->{many_to_many} ) )
        {
            foreach my $many ( @{ $object->{many_to_many} } )
            {
                $object_meta->{many_to_many}->{ $many->{object} } =
                  $many->{member};
            }
        }

        #put objects with foreign_keys at end of list
        if ( $object_meta->{num_foreign_keys} > 0 )
        {
            push( @objects_meta, $object_meta );
        } else
        {
            unshift( @objects_meta, $object_meta );
        }
    }
    return;
}
############################################
# Usage      : private
# Purpose    : Parses object description
#		and creates mvc files
# Returns    : n/a
# Parameters : n/a
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
sub generate_mvc
{
    my @objects = @{ $application_description->[0]->{models} };

    #determine if the many member should be included in create select drop down
    my $no_select = '';

    #set the url prefix for crud pages
    my $url_prefix = '__ADMIN__';
    $url_prefix = $application_description->[0]->{serverstartup}->{url_prefix}
      if (
         defined( $application_description->[0]->{serverstartup}->{url_prefix} )
      );
    if ( length($url_prefix) )
    {
        $url_prefix .= '/' unless ( $url_prefix =~ /\/^/ );
    }

    #Set the environment variables used in generated application
    my @environment_variables = ();
    if ( $application_description->[0]->{serverstartup}->{environment_variables}
      )
    {
        @environment_variables =
          @{ $application_description->[0]->{serverstartup}
              ->{environment_variables} };
    }
    _write_startup_code(
                         application_name      => $application_name,
                         objects               => \@objects,
                         environment_variables => \@environment_variables,
                         url_prefix            => $url_prefix
    );
    _write_routes( objects    => \@objects,
                   url_prefix => $url_prefix );

    # _write_controllers( \@objects );
    _write_views( \@objects );
    _write_layout( \@objects, $url_prefix );
    _write_tests( \@objects, $url_prefix );
    _copy_fragments();

    if ( $application_description->[0]->{authorization} )
    {
        my $auth_content = $application_description->[0]->{authorization};

        #$runtime->{authorization} = $auth_content;
    }

    #paypal
    if ( $application_description->[0]->{paypal} )
    {

        #create conf file
        my $paypal_content = $application_description->[0]->{paypal};
        my $paypal_yml = file( $application_location, 'config', "paypal.yml" );
        if ( -e $paypal_yml )
        {
            msg( "Overiting existing $paypal_yml", 1 );
        } else
        {
            msg( "Creating $paypal_yml", $is_verbose );
        }

        #YAML::Tiny::DumpFile( "$paypal_yml", $paypal_content );

        #copy templates
        for my $file (
                       'cart.html.ep',
                       'view_cart.html.ep',
                       'paypal_transaction.html.ep',
                       'paypal_transaction_failed.html.ep'
          )
        {
            my $cart_template = file( $ZOE_FILES, 'templates', $file );
            copy( $cart_template, dir( $application_location, "templates" ) )
              or croak "Could not copy $cart_template";
        }
    }

    #add application location lib  to -I

    unshift @INC, "" . dir( $application_location, 'lib' );
    foreach my $object (@objects)
    {
        my %linked_create = ();
        _do_create_ddl( $object->{table}, $object->{columns} );
        next if ( $object->{object} =~ /Zoe\:\:DO/ );
        next if ( $object->{object} =~ /Zoe\:\:Runtime/ );

        my $model_code = _get_model_code();

        my $eval_to_string = $object->{eval_to_string} || '';
        $model_code =~ s/\#__EVALTOSTRING__/$eval_to_string/gmx;

        #Authorization
        my $is_auth_object   = 0;
        my $auth_object_info = '';
        my $type             = $object->{object};
        my $lib_path;

        #Set the object_route

        #set the is_auth_object return values
        if ( $application_description->[0]->{authorization} )
        {
            if (
                 (
                   $application_description->[0]->{authorization}->{config}
                   ->{data_object}
                 )
                 && ( $application_description->[0]->{authorization}->{config}
                      ->{data_object}->{auth_object} ) =~ /$object->{object}/
              )
            {
                $is_auth_object = 1;
                $auth_object_info = sprintf(
                    "%s %s 
                                             %s %s
                                             %s %s 
                                             %s %s 
                                             %s %s
                                             %s %s                                           
                                             ",
                    'auth_object',
                    $application_description->[0]->{authorization}->{config}
                      ->{data_object}->{auth_object},
                    'role_column',
                    $application_description->[0]->{authorization}->{config}
                      ->{data_object}->{role_column},
                    'salt_member',
                    $application_description->[0]->{authorization}->{config}
                      ->{data_object}->{salt_member},
                    'password_member',
                    $application_description->[0]->{authorization}->{config}
                      ->{data_object}->{password_member},
                    'user_name_member',
                    $application_description->[0]->{authorization}->{config}
                      ->{data_object}->{user_name_member},
                    'role_object',
                    $application_description->[0]->{authorization}->{config}
                      ->{data_object}->{role_object}
                );
            }
        }
        $model_code =~ s/\#__ISAUTHOBJECT__/$is_auth_object/gmx;
        $model_code =~ s/\#__AUTHOBJECTINFO__/$auth_object_info/gmx;

        #stores object meta info that is used later when writing tests
        $model_code =~ s/\#__TYPE__/$type/mx;
        ##################################################
        # determine number of directores  below DataObject
        # set lib
        my @num_directories = split( /\:\:/xm, $type );
        for ( my $i = 0 ; $i <= $#num_directories ; $i++ )
        {
            $lib_path .= '../';
        }
        $lib_path .= 'lib';
        $model_code =~ s/\#__LIB_PATH__/$lib_path/mx;
        #################################################3
        # Create directories under the lib directory for
        # for objects if  needed.
        # create file handle for model code
        my @model_directories = @num_directories;

        # pop to remove name of model from direcory list
        my $model_name = pop(@model_directories);
        $model_name .= '.pm';
        my $model_path =
          dir( $application_location, 'lib', @model_directories );

        #force $model_path to string by prepending empty string
        unless ( -d $model_path )
        {
            make_path( "" . $model_path )
              or croak "Cannot create $model_path: $!";
        }
        ##################################################
        #set the table name
        ##################################################
        $model_code =~ s/\#__TABLENAME__/$object->{table}/gmx;
        ##################################################
        # set the column names
        # set primary key
        ##################################################
        my @columns = @{ $object->{columns} };
        my $column_names;
        my $foreign_key_code = " ";
        my $primary_key;

        #used to set up the get_column_info method
        my $column_info_string;

        #used to set up the get_column_display method
        my $column_display_string = '';

        #used to set up the is_required_column method
        my $is_required_column_string = '';

        #used to specify default values for drop down
        my $select_options_string = '';
        my $display_as            = '';

        # set the member value shown when by default
        my $to_string_member;

        # column values to be searched in search query
        my $searchable_columns_string = '';
        foreach my $column (@columns)
        {

            if ( $column->{to_string} )
            {
                $to_string_member = $column->{name};
            }
            if (    ( !defined( $column->{searchable} ) )
                 || ( $column->{searchable} == 1 ) )
            {
                $searchable_columns_string .= "'$column->{name}', ";
            }
            $column_names .= $column->{name} . " ";
            if ( defined( $column->{primary_key} )
                 && ( $column->{primary_key} ) )
            {
                $primary_key = $column->{name};
            }

            #foreignkey setup
            if ( defined( $column->{foreign_key} ) )
            {
                $foreign_key_code .=
                  sprintf( q^$sql->{FOREIGNKEY}->{'%s'}->{'%s'} = '%s';^,
                           $column->{name}, $column->{foreign_key},
                           $column->{member} );
                $column_info_string .= "'$column->{name}', 'FOREIGNKEY',\n ";

                if ( $column->{linked_create} )
                {
                    my $rel_object_name = $column->{foreign_key};

                    # $linked_create{$rel_object_name} = $column->{member};
                    $linked_create{ $column->{member} } = $rel_object_name;
                }
            } else
            {
                my $input_type = $column->{input_type} || $column->{type};
                $column_info_string .= "'$column->{name}', '$input_type',\n";
                if ( $input_type eq 'select' )
                {

                   # print "SELECTOPTIONS\n" . Dumper $column->{select_options};
                    my %select_options = %{ $column->{select_options} };
                    my $options_string;
                    foreach my $select_value ( sort keys(%select_options) )
                    {
                        my $select_content = $select_options{$select_value};
                        $options_string .=
"<option value='$select_value'> $select_content </option>\n";
                    }
                    $select_options_string .=
                      "'$column->{name}', q^$options_string^,\n";
                }
            }
            if ( defined( $column->{display} ) )
            {
                chomp( $column->{display} );
                $column_display_string .=
                  "'$column->{name}' => q^$column->{display}^,\n";
            }
            if (    ( defined( $column->{constraints} ) )
                 && ( $column->{constraints} =~ /not\s+null/imx ) )
            {
                $is_required_column_string .= "'$column->{name}' => 1 , \n";
            }
            if ( ( defined( $column->{display_as} ) ) )
            {
                $display_as .= "'$column->{name}', q^$column->{display_as}^,\n";
            }
        }
        my $object_name_short = $type;
        $object_name_short =~ s/\:\:/_/gmx;
        my $object_name_short_lc = lc($object_name_short);
        $model_code =~ s/\#__OBJECTNAMESHORT__/$object_name_short_lc/gmx;
        my $upload_path =
          dir( $application_location, "public", "upload", $object_name_short );
        my $upload_short = dir( "upload", $object_name_short );
        my $public_upload_path = "/upload/$object_name_short/";

        if ( -d "$upload_path" )
        {
            msg( "$upload_path exits", $is_verbose );
        } else
        {
            msg( "Created $upload_path", $is_verbose );
            make_path("$upload_path") or croak "Could not create $upload_path";
        }

        $model_code =~ s/\#__UPLOADPATH__/$upload_short/gmx;
        $model_code =~ s/\#__PUBLICUPLOADPATH__/$public_upload_path/gmx;
        $model_code =~ s/\#__TOSTRINGMEMBER__/$to_string_member/gmx
          if ($to_string_member);
        $model_code =~ s/\#__SEARCHABLECOLUMNS__/$searchable_columns_string/gmx;
        $model_code =~ s/\#__COLUMNS__/$column_names/gmx;
        $model_code =~ s/\#__PRIMARYKEY__/$primary_key/gmx;
        $model_code =~ s/\#__FOREIGNKEY__/$foreign_key_code/gmx;
        $model_code =~ s/\#__COLUMNINFO__/$column_info_string/gmx;
        $model_code =~ s/\#__SELECTOPTIONS__/$select_options_string/gmx;
        $model_code =~ s/\#__DISPLAYAS__/$display_as/gmx;
        $model_code =~ s/\#__COLUMNDISPLAY__/$column_display_string/gmx;
        $model_code =~ s/\#__ISREQUIRED__/$is_required_column_string/gmx;

        ##################################################
        # set has many relationships
        # linked create - show create for child /parent objects
        ##################################################

        my $has_many_code = "";
        if ( defined( $object->{has_many} ) )
        {
            foreach my $has_many ( @{ $object->{has_many} } )
            {
                my $member = $has_many->{member};
                $has_many_code .= sprintf(
q^      #create array ref for has_many object unless it already exists 
                       #object         #member             #fk_column 
                        $sql->{HASMANY}->{'%s'} = [] unless ( ref ($sql->{HASMANY}->{'%s'}) eq 'ARRAY' ); 
                        #push member to key hash into array ref  
                        push(@{$sql->{HASMANY}->{'%s'} }, {'%s' => '%s' });^,
                    $has_many->{object},    #object name
                    $has_many->{object},    #same
                    $has_many->{object},    #same
                    $has_many->{member},    #object member
                    $has_many->{key},       #foreign key
                );
                if ( $has_many->{linked_create} )
                {
                    my $rel_object_name = $has_many->{object};

                    #$linked_create{$rel_object_name} = $has_many->{member};
                    $linked_create{ $has_many->{member} } = $rel_object_name;

                }
                if ( $has_many->{no_select} )
                {
                    $no_select .= "'$member', 1, ";
                }
            }
        }
        $model_code =~ s/\#__HASMANY__/\#__HASMANY__\n$has_many_code\n/gmx;
        ##################################################
        # set many to many relationships
        ##################################################
        my $many_to_many_code = "";
        if ( defined( $object->{many_to_many} ) )
        {
            #print Dumper $object;
            foreach my $many ( @{ $object->{many_to_many} } )
            {
                my $member = $many->{member};
                $many_to_many_code .=
                  sprintf(
q^      $sql->{MANYTOMANY}->{'%s'} = [] unless ( ref ($sql->{MANYTOMANY}->{'%s'}) eq 'ARRAY' ); ^
                      . q^      $many_description = { ^
                      . q^          table            => '%s', ^
                      . q^          my_column        => '%s', ^
                      . q^          relationship_col => '%s', ^
                      . q^          member           => '%s', ^
                      . q^          primary_key      => '%s', ^
                      . q^      }; ^
                      . q^      push(@{ $sql->{MANYTOMANY}->{'%s'}}, $many_description ); ^,
                    $many->{object},           $many->{object},
                    $many->{table},            $many->{my_column},
                    $many->{relationship_col}, $many->{member},
                    $many->{primary_key},      $many->{object}
                  );

                #create the tables for the many to many relationships
                my $many_to_many_col_yml = <<"YML";
-  name: ID
   type: integer
   constraints:
   primary_key: 1
-  name: $many->{my_column}
   type: integer
   constraints: 'not null'
-  name: $many->{relationship_col}
   type: integer
   constraints: 'not null'
YML
                my $many_to_may_co_ref = YAML::XS::Load($many_to_many_col_yml);
                _do_create_ddl( $many->{table}, $many_to_may_co_ref );
                if ( $many->{linked_create} )
                {
                    my $rel_object_name = $many->{object};

                    #$linked_create{$rel_object_name} = $many->{member};
                    $linked_create{ $many->{member} } = $rel_object_name;
                }
                if ( $many->{no_select} )
                {
                    $no_select .= "'$member', 1, ";
                }
            }
        }
        $model_code =~ s/\#__NOSELECT__/$no_select/gmx;
        $model_code =~
          s/\#__MANYTOMANY__/\#__MANYTOMANY__\n$many_to_many_code\n/gmx;
        my $linked_create_code = '';
        foreach my $rel_member ( keys(%linked_create) )
        {
            my $object_name = $linked_create{$rel_member};

            #$linked_create_code .= "'$object_name'=> '$rel_member',\n";
            $linked_create_code .= " '$rel_member'=> '$object_name',\n";
        }
        $model_code =~ s/\#__LINKEDCREATE__/$linked_create_code/gmx;
        my $model_file = file( $model_path, $model_name );
        open( my $MODEL_CODE, ">", "$model_file" )
          or croak "Could not write to $model_file: $!";
        print $MODEL_CODE $model_code;
        close($MODEL_CODE);

        #_do_create_ddl( $object->{table}, $object->{columns} );

        eval "use " . $object->{object};
    }
    _set_initial_values( \@objects );
    $runtime->{name} = time();

    my $shell_pl = read_file( file( $ZOE_FILES, 'templates', 'shell.pl.tpl' ) );
    my $repleval = _get_repl_eval( \@objects );
    $shell_pl =~ s/\#__REPLEVAL__/$repleval/gmx;
    my $use_statements = _get_use_statement( \@objects );
    $shell_pl =~ s/\#__USESTATEMENT__/$use_statements/gmx;
    my $file = file( $application_location, 'script', 'shell.pl' );
    write_file( "$file", $shell_pl ) or croak "$file: $!";

    chmod 0750, "" . $file or die "Couldn't chmod $file: $!";

    #do imports
    _import_files();
    return;

}

sub _set_initial_values
{
    return if ($no_ddl);
    if (@import_files)
    {

        msg( "--import specified;  intial_values ignored from app_files",
             $is_verbose );

        return;
    }

    my $time        = time();
    my $sqla        = SQL::Abstract::More->new();
    my $db_yml_tmp  = file( './', 'db.yml' );
    my $objects_ref = shift;
    my $do          = Zoe::DataObject->new( runtime => $runtime )
      or die "$db_yml_tmp $!";
    my $application_DBH = $do->get_database_handle();
    my $return;

    #get keys from object_ref and if == object add to use statement
    foreach my $object ( @{$objects_ref} )
    {
        my $object_type = $object->{object};
        ###
        # save initial_values
        #
        if ( $object->{initial_values} )
        {
            $return = {} unless $return;

            foreach my $initial_value ( @{ $object->{initial_values} } )
            {

                #$object_type->import;
                my $initial_object = $object_type->new( %{$initial_value} );

                #print "INITIAL VALUES  $object_type\n"
                # . Dumper %{$initial_value};
                $initial_object->save;

            }

            #create backup yml
            my @all = $object_type->find_all();

            $return->{$object_type} = \@all;

        }
        ##do inserts on join tables
        if ( $object->{insert} )
        {
            foreach my $insert ( @{ $object->{insert} } )
            {

                #print Dumper $insert;
                my $table       = $insert->{table};
                my $values_list = $insert->{values};
                foreach my $values (@$values_list)
                {
                    my ( $sql, @bind ) =
                      $sqla->insert( -into   => $table,
                                     -values => $values, );
                    my $sth = $application_DBH->prepare($sql);
                    $sqla->bind_params( $sth, @bind );
                    $sth->execute;
                }
            }
        }

    }
    if ($return)
    {
        
        my $file_name = 'backup_' . 'all_models_' . $time . '.yaml';
        my $save_file = file( $application_location, '..', 'yaml', 'import', $file_name );
         local $YAML::SortKeys = 0;
        YAML::XS::DumpFile( $save_file, $return )
          or croak "could not save $file_name";
    }
}

sub _do_create_ddl
{
    return if ($no_ddl);
    my $table           = shift;
    my $columns         = shift;
    my $sqlBuilder      = SQL::Abstract->new( case => 'lower' );
    my $db_yml_tmp      = file( './', 'db.yml' );
    my $do              = Zoe::DataObject->new( runtime => $runtime );
    my $application_DBH = $do->get_database_handle();
    my ( $cmd, @bind );

    #drop table if exists
    ( $cmd, @bind ) = $sqlBuilder->generate( 'drop table if exists ', $table );
    $application_DBH->do($cmd);

    #create the tables
    #generate ddl and translate for db specified
    my $ddl = " create table $table ( ";
    foreach my $column ( @{$columns} )
    {
        my $primary_key = '';
        $primary_key = 'PRIMARY KEY AUTOINCREMENT'
          if ( $column->{primary_key} );
        $ddl .= sprintf( q^%s %s %s %s, ^,
                         $column->{name}, $column->{type}, $primary_key,
                         $column->{constraints} || " " );
    }
    $ddl .= ' LAST_MOD timestamp );';
    open( my $TEMPSQL, ">", "tmp.sql" )
      or croak("Could not create temporary sql script: ./tmp.sql");
    my $database_type = $application_DBH->get_info(17);
    print $TEMPSQL $ddl;
    close $TEMPSQL;
    my $sql_translator = SQL::Translator->new( debug => 1, );
    my $create_ddl =
      $sql_translator->translate(
                                  from     => 'SQLite',
                                  to       => $database_type,
                                  filename => './tmp.sql',
      )
      or croak "Could not translate ddl sql to $database_type "
      . $sql_translator->error;
    unlink('./tmp.sql');
    msg( "Creating table: $table", $is_verbose );

    #sql tranlsate returns sql with multiple commands
    #split by ; and execute each
    my @sql_commands = split( /\;/x, $create_ddl );
    foreach my $sql (@sql_commands)
    {
        msg( $sql, $is_verbose );
        $application_DBH->do($sql)
          or croak $application_DBH->errstr . " \nSQL = $sql"
          unless ( $sql =~ /\s*\n$/ );
    }
    return;
}

sub _get_model_code
{
    return read_file( file( $ZOE_FILES, 'templates', 'model.tpl' ) );
}

sub _write_startup_code
{
    my %arg                   = @_;
    my $package_name          = $arg{application_name};
    my $objects_ref           = $arg{objects};
    my @environment_variables = @{ $arg{environment_variables} };
    my $url_prefix            = $arg{url_prefix} || '';
    my $use_statement_string  = _get_use_statement($objects_ref);
    my $startup_controller_file =
      file( $ZOE_FILES, 'templates', 'startup_controller.tpl' );
    my $startup_code = read_file($startup_controller_file);
    $startup_code =~ s/\#__PACKAGENAME__/$package_name/gmx;
    ##
    # set the environment variables
    ##my
    my $environment_str;

    foreach my $entry (@environment_variables)
    {
        $environment_str .=
          sprintf( '$ENV{%s} = "%s"' . ";\n", $entry->{key}, $entry->{value} );

    }
    $startup_code =~ s/\#__ENVIRONMENTVAR__/$environment_str/gmx;
    $startup_code =~ s/\#__URLPREFIX__/$url_prefix/gmx;
    $startup_code =~ s/\#__USESTATEMENTS__/$use_statement_string/gmx;
    my $startup_script = decamelize($application_name);
    $startup_code =~ s/\#__STARTUPSCRIPT__/$startup_script/gmx;
    my $file = file( $application_location, 'lib', $application_name . ".pm" );
    write_file( "$file", $startup_code ) or croak "$file: $!";
    return;
}

sub _write_routes
{
    my %arg        = @_;
    my $url_prefix = '';
    $url_prefix = $arg{url_prefix} if ( defined( $arg{url_prefix} ) );
    my $objects_ref = $arg{objects};
    my $begin_route =
      "###Begin Generated Routes -Content will be replaced on generate";
    my $end_route  = "###End Generated Routes";
    my $routes_yml = $begin_route . "\n";

    ###add runtime routes
    my $additional_routes =
      read_file( file( $ZOE_FILES, 'templates', 'additional_routes.tpl' ) );
    $additional_routes =~ s/\#__URLPREFIX__/$url_prefix/gmx;
    $routes_yml .= $additional_routes . "\n";

    foreach my $object ( @{$objects_ref} )
    {

        #route paths are based on objectnames
        #hello::world will create  /hello/world
        my $object_name = $object->{object};

        $object_name =~ s/\:\:/_/gmx;
        my $object_route = $object->{object};
        $object_route =~ s/\:\:/\//g;

        $object_route = lc($object_route);

        my $controller_name =
          $application_name . '::' . $object_name . 'Controller';
        $object_name = lc($object_name);
        my $routes_fragment_file =
          file( $ZOE_FILES, 'templates', 'routes.tpl' );
        my $routes_code = read_file($routes_fragment_file);
        $routes_code =~ s/\#__OBJECTNAME__/$object_name/gmx;
        $routes_code =~ s/\#__OBJECTROUTE__/$object_route/gmx;
        $routes_code =~ s/\#__URLPREFIX__/$url_prefix/gmx;

        #$routes_code =~ s/\#__CONTROLLER__/$controller_name/gmx;
        $routes_code =~ s/\#__CONTROLLER__/'Zoe::ZoeActionController'/gmx;
        $routes_code =~ s/\#__OBJECTTYPE__/$object->{object}/gmx;

        $routes_yml .= $routes_code;
    }
    $routes_yml .= $end_route;

    #my $routes_file = file( $application_location, 'config', "routes.yml" );

    $routes_yml .= "\n" unless ( $routes_yml =~ /\n\n$/sgm );

    #add routes to Runtime
    my $routes = YAML::XS::Load($routes_yml);

    #print Dumper $routes;

    #get routes from the sites section
    $runtime->{routes} = $routes;

}

sub _write_views
{
    my $objects_ref = shift;

    #set and create template directory
    my $from = dir( $ZOE_FILES, 'templates', 'zoe' );
    my $to = dir( $application_location, "templates", 'zoe' );
    
    dircopy( $from, $to )  or croak "Could not copy $from to $to :$!\n";
    return;
}

#set the use statements for use with the shell
sub _get_repl_eval
{
    my $objects_ref = shift;
    my $use_string  = '';
    foreach my $object ( @{$objects_ref} )
    {
        my $object_name = $object->{object};
        $use_string .= "\$repl->eval('use $object_name');\n";
    }
    return $use_string;
}

sub _get_use_statement
{
    my $objects_ref = shift;
    my $use_string  = '';
    foreach my $object ( @{$objects_ref} )
    {
        my $object_name = $object->{object};
        $use_string .= "use $object_name;\n";
    }
    return $use_string;
}

sub _write_controllers
{
    my $objects_ref = shift;

    #get keys from object_ref and if == object add to use statement
    my $use_statement_string = _get_use_statement($objects_ref);
    foreach my $object ( @{$objects_ref} )
    {
        my $object_name       = $object->{object};
        my $object_name_short = $object_name;

        #$object_name_short =~ s/.*\:\:(\w+)$/$1/gmx;
        $object_name_short =~ s/\:\:/_/gmx;
        my $controller_name = $object_name_short . 'Controller';
        my $template_dir    = lc($controller_name);
        my $package_name    = $application_name . '::' . $controller_name;
        my $upload_path =
          dir( $application_location, "public", "upload", $object_name_short );
        my $upload_short = dir( "upload", $object_name_short );
        my $public_upload_path = "/upload/$object_name_short/";

        if ( -d "$upload_path" )
        {
            msg( "$upload_path exits", $is_verbose );
        } else
        {
            msg( "Created $upload_path", $is_verbose );
            make_path("$upload_path") or croak "Could not create $upload_path";
        }

        #my $tmp_file = file ($ZOE_FILES, "templates", "object_controller.tpl");
        my $controller_code = read_file(
                "" . file( $ZOE_FILES, "templates", "object_controller.tpl" ) );
        $controller_code =~ s/\#__PACKAGENAME__/$package_name/gmx;
        $controller_code =~ s/\#__OBJECTNAME__/$object_name/gmx;
        $controller_code =~ s/\#__TEMPLATEDIR__/$template_dir/gmx;
        $controller_code =~ s/\#__USESTATEMENTS__/$use_statement_string/gmx;
        $controller_code =~ s/\#__UPLOADPATH__/$upload_short/gmx;
        $controller_code =~ s/\#__PUBLICUPLOADPATH__/$public_upload_path/gmx;
        my $controller_file =
          file( $application_location, 'lib', $application_name,
                $controller_name . ".pm" );

        if ( ( -e "$controller_file" ) && ( !$do_replace_existing ) )
        {
            msg(
"Controller $controller_file exists--specify -replace to overwrite",
                $is_verbose
            );
        } else
        {
            msg( "Writing Controller: $controller_file", $is_verbose );
            write_file( $controller_file, $controller_code );
        }
    }
    return;
}
1;
__DATA__

=head1 NAME

zoe-generator - Application Scaffolding for L<Mojolicious> Framework

=head1 VERSION

This documentation refers to Zoe, and the zoe-generator 

=head1 USAGE

	zoe-generator -versose       Enables verbose output
		     -no_ddl        Tables will not be written to
				    specified database
		     -app_file      Application description file

=head1 SYNOPSIS

The zoe-generator script generates Model, View, and Controller code for use with Mojolicious.
Object details, fields, table, relationships are defined in YAML in a file passed to
zoe-generator by the -app_file command argument.  It also generates a test script (t/00.crud.t),
 that verifies create, update, and delete for all
objects specified in the application description file work via the object and http interface.

=head1 THE Application Description File

Example file below:

        application_name: Testing
        location: /var/scripts/testing_home
        database:
          dev:
            type: sqlite
            dbfile: /var/scripts/testing_home/app.db
         objects:
          - object: BFTG::DO::TestObject3
            many_to_many:
         -  object: BFTG::DO::TestObject2
            table: TestObject2XTestObject3
            my_column: TestObject3_ID
            relationship_col: TestObject2_ID
            member: TestObject2_LIST
            primary_key: ID
            table: TestObject3
            columns:
             -  name: ID
            type: integer
            constraints:
            primary_key: 1
             -  name: name
            type: varchar
            constraints: "not null"
            to_string: 1
            -  name: image
            type: varchar
            input_type: file
            constraints: "not null"
            display: |
                return "<img width='140' height='140' class='img-rounded' src='" . $object->get_image() . "'/>";
          - object: BFTG::DO::TestObject2
            many_to_many:
             -  object: BFTG::DO::TestObject3
            table: TestObject2XTestObject3
            my_column: TestObject2_ID
            relationship_col: TestObject3_ID
            member: TestObject3_LIST
            primary_key: ID
            table: TestObject2
            columns:
             -  name: ID
            type: integer
            constraints:
            primary_key: 1
             -  name: name
            type: varchar
            constraints: "not null"
            to_string: 1
             -  name: TestObject1_ID
            type: integer
            constraints:
            foreign_key: BFTG::DO::TestObject1
            member: TestObject1
          - object: BFTG::DO::TestObject1
            has_many:
             -  object: BFTG::DO::TestObject2
            key: TestObject1_ID
            member: TestObject2_LIST
            table: TestObject1
            columns:
             -  name: ID
            type: integer
            constraints:
            primary_key: 1
             -  name: name
            type: varchar
            constraints: "not null"
            to_string: 1

=head2 application_name

The name of the application; must begin with an uppercase.

=head2 location

Application path

=head2 database

Begins database details
The keys required depend on the database driver.  The keys supported include:

=head3 type

Database Type

=head3 dbname

Database Name/Schema

=head3 host

Database hostname or ip

=head3 port

Database port number

=head3 dbuser

Database user account

=head3 dbpassword

Database password

=head3 dbfile

Used with sqlite to specify the database file

=head2 objects

Begins object definition section of the file

=head3 object

Fully qaulified name of the object to be generated

=head3 table

The table that maps to the object

=head3 has_many

Begin the Has many declarations

=head4 object

Fully qualified object name for which said object has many

=head4 key

The column in the has_many objects' talble  that corresponds to the defining
object

=head4 member

The member variable that contains the has_many objects

=head3 many_to_many

Begin the many to many object declaration

=head4 object

Fully qualified object name for which said object has many

=head4 table

The relationship table that holds the many to to many relationship

=head4 my_column

The column the coresponds to defining objects primary key

=head4 relationship_col

The column the coresponds to related objects primary key

=head4 member

The member variable that contains the related objects

=head4 primary_key

Column within the relationship table that specifies the primary key

=head3 columns

Begin the column defininition

=head4 name

The column name

=head4 type

The column type can be varchar| real | integer | numeric| or what ever your db supports.  This value gets used by  L<SQL::Translator>.

=head4 primary_key

set to 1 if the specified column is a primary key

=head4 to_string

Specify if column value is to be returned when to_string is called on associated object
=head4 constraints
The column constraints to be used when generating the ddl

=head4 input_type

optional parameter specifies the value passed to the type argument of the input "<input>" tag

=head4 display

This value is evaluated via eval and passed as the value of the member/column when the object is displayed
=head1 NOTE

 column types map to sqlite column types.  If another database type is used the the ddl
is translated via SQL::Translator
the dbtype value should match the value returned by the ->get_info(17) method of the
database handle

=head1 SEE ALSO

L<Zoe::DataObject>
L<Zoe::Helpers>

=head1 AUTHOR

Dinni Bartholomew
