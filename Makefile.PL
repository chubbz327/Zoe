use strict;
use warnings;
use ExtUtils::MakeMaker;
WriteMakefile(
  VERSION   => '0.60',
  AUTHOR       => 'dinni bartholomew <dinnibartholomew@gmail.com>',
  LICENSE      => 'artistic_2',
  MIN_PERL_VERSION => '5.010001',
  PREREQ_PM => {
                'Mojolicious' => '4.22',
                'DBI' => '1.623',
                'DBD::SQLite' => '1.37',
                'SQL::Abstract::More' => '1.15',
                'YAML::Tiny' => '1.51',
                'SQL::Abstract' => '1.73',
                'String::CamelCase' => '0.02',
                'Lingua::EN::Inflect' =>  '1.895',
                'File::Slurp' => '9999.19',
                'File::Copy::Recursive' => '0.38',
                'File::Touch' => '0.08',
                'SQL::Translator' => '0.11016',
                'Path::Class' => '0.32',
                'Data::GUID' => '0.046',
                'Log::Message::Simple' => '0.08',
                'DateTime'=> '0', 
                'DateTime::Format::DBI'=> '0',
                'JSON::Parse' => '0', 
		'YAML::XS' => '0',
              },
  EXE_FILES => [qw( script/zoe script/zoe-generator )],
  test      => {TESTS => 't/*.t'}
);
