Zoe -  zoe-generator - Application Scaffolding for Mojolicious Framework

#SYNOPSIS

The zoe-generator script generates Model, View, and Controller code for use with Mojolicious.  
Object details, fields, table, relationships are defined in YAML in a file passed to 
zoe-generator by the -app_file command argument.


#INSTALL
#make sure cpan is set to follow
cpan> o conf prerequisites_policy follow
cpan> o conf commit

#install via cpan

$ tar -xzvf Zoe-VER.tar.gz; cd Zoe-VER; cpan -i .

#Running 

zoe-generator --app_file <yaml application description>

1;


