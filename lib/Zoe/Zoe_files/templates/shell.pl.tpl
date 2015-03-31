#!/usr/bin/env perl
use Devel::REPL;
use FindBin;
 
use lib "$FindBin::Bin/../lib";
use Zoe::DataObject;

#__USESTATEMENT__

my $repl = Devel::REPL->new;
 
$repl->eval( 'use lib ' . " $FindBin::Bin/../lib" );
$repl->eval('use Zoe::DataObject');
$repl->eval('use Data::Dumper');
$repl->eval('use YAML::XS');

#__REPLEVA2L__

$repl->load_plugin($_) for qw(History LexEnv Colors
  Completion
  CompletionDriver::INC
  CompletionDriver::LexEnv
  CompletionDriver::Keywords
  CompletionDriver::Methods
  DumpHistory
  ReadLineHistory);
$repl->run

