Zoe - application generation via yaml description file

#SYNOPSIS
The purpose of Zoe, is to generate applications based on meta data. Applicaitons 
are described via yaml description file. 

The zoe-generator script reads the description file and  generates :
	1. Model, View, and Controller code 
	2. RESTFul JSON webservices for models described
	3. ORB for model persistance
	4. Admin Web interface with authentication and authorization


#INSTALL
#make sure cpan is set to follow
cpan> o conf prerequisites_policy follow
cpan> o conf commit

#install via cpan

$ tar -xzvf Zoe-VER.tar.gz; cd Zoe-VER; cpan -i .

#Running 

zoe-generator --app_file <yaml application description>

#Anatomy of the Application Description File
An example yaml is shown below

1;


