#!/bin/bash

 curl -L http://cpanmin.us | perl - --sudo App::cpanminus
/usr/local/bin/cpanm Class::MOP;
/usr/local/bin/cpanm DBI;
/usr/local/bin/cpanm Data::GUID;
/usr/local/bin/cpanm Data::Serializer;
/usr/local/bin/cpanm Data::Dumper::HTML;
/usr/local/bin/cpanm DateTime::Format::DBI;
/usr/local/bin/cpanm DateTime;
/usr/local/bin/cpanm Digest::SHA1
/usr/local/bin/cpanm File::Copy::Recursive
/usr/local/bin/cpanm File::Slurp;
/usr/local/bin/cpanm File::Touch;
/usr/local/bin/cpanm Hash::Merge;
/usr/local/bin/cpanm JSON::Parse
/usr/local/bin/cpanm Lingua::EN::Inflect
/usr/local/bin/cpanm List::MoreUtils
/usr/local/bin/cpanm Net::LDAP;
/usr/local/bin/cpanm Path::Class;
/usr/local/bin/cpanm SQL::Abstract::More;
/usr/local/bin/cpanm SQL::Abstract;
/usr/local/bin/cpanm SQL::Translator;
/usr/local/bin/cpanm String::CamelCase
/usr/local/bin/cpanm YAML::Tiny;
/usr/local/bin/cpanm YAML::XS;
curl -L cpanmin.us | perl - -n Mojolicious
