use strict;
use warnings;
use ExtUtils::MakeMaker;
WriteMakefile(
 VERSION          => '0.35',
 AUTHOR           => 'dinni bartholomew <dinnibartholomew@gmail.com>',
 LICENSE          => 'artistic_2',
 MIN_PERL_VERSION => '5.010001',
 PREREQ_PM        => {
  'Mojolicious'           => '4.22',
  'Class::MOP'            => '0',
  'DBD::SQLite'           => '1.37',
  'DBI'                   => '1.623',
  'Data::GUID'            => '0.046',
  'Data::Serializer'      => '0',
  'DateTime'              => '0',
  'DateTime::Format::DBI' => '0',
  'Digest::SHA1'          => '0',
  'File::Copy::Recursive' => '0.38',
  'File::Slurp'           => '9999.19',
  'File::Touch'           => '0.08',
  'JSON::Parse'           => '0',
  'Lingua::EN::Inflect'   => '1.895',
  'List::MoreUtils'       => '0',
  'Net::LDAP'             => '0',
  'Path::Class'           => '0.32',
  'SQL::Abstract'         => '1.73',
  'SQL::Abstract::More'   => '1.15',
  'SQL::Translator'       => '0.11016',
  'String::CamelCase'     => '0.02',
  'YAML::Tiny'            => '1.51',
  'YAML::XS'              => '0',
  'Business::PayPal::NVP' => '0',
  'JSON::Any' => '0',
  'Devel::REPL' => '0',
  'Lexical::Persistence' => '0',
  'Data::Dump::Streamer'=> '0',
  
 },
 EXE_FILES => [qw( script/zoe-generator )],
 test      => { TESTS => 't/*.t' }
);
