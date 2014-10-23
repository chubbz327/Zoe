Zoe -  zoe-generator - Application Scaffolding for Mojolicious Framework

#SYNOPSIS

The zoe-generator script generates Model, View, and Controller code for use with Mojolicious.  
Object details, fields, table, relationships are defined in YAML in a file passed to 
zoe-generator by the -app_file command argument.


#INSTALL
#make sure cpan is set to follow
cpan> o conf prerequisites_policy follow
cpan> o conf commit

#install pre-reqs
./prerequisites.sh
perl Makefile.PL
make 
make test 
sudo make install 


#Running 

Fire up the web insterface via zoe daemon
and point your web browser to http://localhost:3456

OR

zoe-generator --app_file <yaml application description>

1;


