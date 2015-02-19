use Mojo::Base -strict;

#use Test::More tests => 'no_plan';
use Test::More 'no_plan';
use Test::Mojo;
my $cwd; #current working directory

BEGIN {
    use_ok("File::Basename");
    use_ok("File::Spec::Functions");
    use_ok("Path::Class");
    use_ok("Mojo::Asset::File");
    use_ok("File::Slurp");
    use_ok("File::Path");

    $cwd = File::Spec->rel2abs( catdir( dirname(__FILE__) ) );
    use File::Basename 'dirname';
    use File::Spec::Functions 'catdir';
    use File::Path qw(make_path remove_tree);

    unshift @INC, "" . dir( $cwd, '..', 'lib' );
    use_ok('Zoe');
    use_ok('Zoe::DataObject');
}

my $t = Test::Mojo->new('Zoe') or die 'Could not start Zoe';
$t->app->log->level('debug');
$t->get_ok('/')->status_is(200)->content_like(qr/Zoe/i);

#confirm that app generation works via post to the web interface
my $tpl = file( $cwd, 'test.yml.tpl' );
die 'Could not read application description file ./test.yml.tpl: ' . $!
  unless ( -e $tpl );
my $tpl_content = read_file($tpl);

my $app_location = dir( $cwd, 'tmp' );
make_path("$app_location") or die ("Could not create $app_location") unless (-d "$app_location" );

$tpl_content =~ s/\#__CWD__/$app_location/gmx;
my $file = file( $cwd, 'test.yml' );
write_file( $file, $tpl_content );

Zoe->new()->generate_application(
                application_config_file => [$file],
                is_verbose              => 1
            );


my $generated_test = file($app_location, 'employee' , 't', '00.crud.t');
 use Test::Harness;
 runtests( ["$generated_test"]);
  
#remove_tree("$app_location");
  
#unlink($file);
