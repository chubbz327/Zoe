package Zoe::Runtime::Database;
use Mojo::Base 'Zoe::Runtime';

sub new
{
    my $class = shift;
    my %arg   = @_;
    my $self = {
        type        => undef, #database type (mysql | sqlite| perl DBD driver name])
        dbfile      => undef, #path to database 
                              # required if type is sqlite 
        dbname      => undef, #database name
        port        => undef, #database port
        host        => undef, #databse host
        dbuser      => undef, #database user name
        dbpassword  => undef, #database user password
        is_verbose  => undef, #verbose logging (1| 0)  
      
        mandatory_fields => [ 'type'],    #mandatory fields
       
        
        %arg
    };
    return bless $self, $class;
}

sub check_valid {
    #if type is sqlite ->dbfile is required
    #else all other params are required
    
    my $self = shift;
    my $type = $self->{type};
    my @not_valids = ();
    
    push(@not_valids, 'type') unless (defined($self->{type}));
    if ($type =~ /sqlite/imx){
        push(@not_valids, 'type');
    }else {
        my @list = ('dbname', 'port', 'host', 'dbuser', 'dbpassword');
        
        foreach my $field (@list) {
            push(@not_valids, $field) unless ( defined($self->{$field}) );
           
        }
    }
    return @not_valids;
}


1;
__DATA__

=head1 NAME

ZOE::Runtime::Database

=head1 Description

Stores the runtime Database details;  
Database parameters are stored in the runtime.yml file or passed as 
key values to the Zoe::Runtime::Database constructer
keys and description below

        type        database type (mysql | sqlite| perl DBD driver name])
        dbfile      path to database 
                    required if type is sqlite 
        dbname      database name
        port        database port
        host        databse host
        dbuser      database user name
        dbpassword  database user password
        is_verbose  verbose logging (1| 0)  
      
        mandatory_fields => [ 'type'],    #mandatory fields
                        #if type is sqlite ->dbfile is required
                        #else all other params are required

=head1 YML Examples    

Sqlite example:

        database:
          type: sqlite
          dbfile: /var/apps/myapp/app.db
          is_verbose: 1

All other DB example:

        database:
           type: mysql
           dbname: mydatabase
           port: 3306
           host: dbhost
           dbuser: dbuser
           dbpassword: butt3rSk0tcH!
           is_verbose: 1

=head1 Author
    
dinnibartholomew@gmail.com
    
=cut

