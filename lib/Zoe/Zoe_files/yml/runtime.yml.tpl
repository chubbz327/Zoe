
models:
###################Runtime         ###############
  - object: __APPLICATION_NAME__::Runtime::Runtime
    has_many:
     -  object: __APPLICATION_NAME__::Runtime::Database
        key: Runtime_ID
        member: database
        linked_create: 1
        no_select: 1
     -  object: __APPLICATION_NAME__::Runtime::ServerStartup
        key: Runtime_ID
        member: serverstartup
        linked_create: 1
        no_select: 1
     -  object: __APPLICATION_NAME__::Runtime::Model
        key: Runtime_ID
        member: models
        linked_create: 1
        no_select: 1

       
    table: __APPLICATION_NAME___RUNTIME_Runtime
    columns:
     -  name: ID
        type: integer
        primary_key: 1
     -  name: name
        type: text
        constraints: "not null"
        to_string: 1        
        
###################Database        ###############
  - object: __APPLICATION_NAME__::Runtime::Database
    table: __APPLICATION_NAME___RUNTIME_Database
    columns:
     -  name: ID
        type: integer
        primary_key: 1
     -  name: name
        type: text
        constraints: "not null"
        to_string: 1
     -  name: Runtime_ID
        type: integer
        constraints:
        foreign_key: __APPLICATION_NAME__::Runtime::Runtime
        member: Runtime

     -  name: type
        type: text   
        input_type: select
        select_options:
          mysql: mysql
          postgres: postgres
          sqlite: sqlite
     -  name: dbname
        type: text

     -  name: port
        type: text
         
     -  name: host
        type: text
      
     -  name: dbuser
        type: text
    
     -  name: dbfile
        type: text        

     -  name: is_verbose
        type: text

####################Environment Variables ###############
###Environment Variable
  - object: __APPLICATION_NAME__::Runtime::EnvironmentVariable				

    table: __APPLICATION_NAME___RUNTIME_EnvironementVariables
    columns:
     -  name: ID
        type: integer
        primary_key: 1
     -  name: name
        type: text
        constraints: "not null"
        to_string: 1
     -  name: value
        type: text
        constraints: "not null"
     -  name: ServerStartup_ID
        type: integer
        foreign_key: __APPLICATION_NAME__::Runtime::ServerStartup
        member: Runtime
        constraints: "not null"
        
#############################SERVER STARTUP #################################  

  - object: __APPLICATION_NAME__::Runtime::ServerStartup
    has_many:
     -  object: __APPLICATION_NAME__::Runtime::EnvironmentVariable	
        key: ServerStartup_ID
        member: environment_variables
        linked_create: 1
    table: __APPLICATION_NAME___RUNTIME_ServerStartup
    columns:
     -  name: ID
        type: integer
        primary_key: 1
     -  name: Runtime_ID
        type: integer
        foreign_key: __APPLICATION_NAME__::Runtime::Runtime
        member: Runtime
        
        
        
     -  name: application_name
        type: text
        constraints: "not null"  
        to_string: 1
                   
     -  name: location
        type: text
        constraints: "not null"        

#############################COLUMNS              #################################  
  - object: __APPLICATION_NAME__::Runtime::Column

    table: __APPLICATION_NAME___RUNTIME_Column
    columns:
     -  name: ID
        type: integer
        primary_key: 1
     -  name: name
        type: text
        constraints: "not null"
        to_string: 1
        
     -  name: Model_ID
        type: integer
        foreign_key: __APPLICATION_NAME__::Runtime::Model
        member: Model

     -  name: type
        type: text        
     -  name: primary_key
        type: text
     -  name: constraints
        type: text        
     -  name: input_type
        type: text

     -  name: display
        type: text        
     -  name: select_options
        type: text
     -  name: member
        type: text        
     -  name: foreign_key
        type: text
#############################HasMany            #################################  

  - object: __APPLICATION_NAME__::Runtime::HasMany

    table: __APPLICATION_NAME___RUNTIME_HasMany
    columns:
     -  name: ID
        type: integer
        primary_key: 1
     -  name: object
        type: text
        constraints: "not null"
        to_string: 1


     -  name: key
        type: text  
        constraints: "not null"              
     -  name: member
        type: text                        
        constraints: "not null"

     -  name: linked_create
        type: text        
     -  name: no_select
        type: text       
     -  name: multiple
        type: text  
     
     -  name: Model_ID
        type: integer
        foreign_key: __APPLICATION_NAME__::Runtime::Model
        member: Model
        
#############################ManyToMany            #################################  

  - object: __APPLICATION_NAME__::Runtime::ManyToMany

    table: __APPLICATION_NAME___RUNTIME_ManyToMany
    columns:
     -  name: ID
        type: integer
        primary_key: 1
        
        
     -  name: object
        type: text
        constraints: "not null"
        to_string: 1

     -  name: table_
        type: text  
        constraints: "not null"   
                   
     -  name: my_column
        type: text                        
        constraints: "not null"

     -  name: relationship_col
        type: text                        
        constraints: "not null"

     -  name: member
        type: text                        
        constraints: "not null"

     -  name: primary_key
        type: text                        
        constraints: "not null"       

     -  name: linked_create_
        type: text   
        
             
     -  name: no_select
        type: text       

     -  name: Model_ID
        type: integer
        foreign_key: __APPLICATION_NAME__::Runtime::Model
        member: Model
                
#############################Model             #################################  

  - object: __APPLICATION_NAME__::Runtime::Model				
    has_many:
     -  object: __APPLICATION_NAME__::Runtime::Column
        key: Model_ID
        member: columns
        linked_create: 1
     -  object: __APPLICATION_NAME__::Runtime::HasMany
        key: Model_ID
        member: has_many
        linked_create: 1


    table: __APPLICATION_NAME___RUNTIME_Model
    columns:
     -  name: ID
        type: integer
        primary_key: 1
     -  name: object
        type: text
        constraints: "not null"
        to_string: 1

     -  name: table_
        type: text

     -  name: Runtime_ID
        type: integer
        constraints:
        foreign_key: __APPLICATION_NAME__::Runtime::Runtime
        member: Runtime
 
 
       

          