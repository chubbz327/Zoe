serverstartup:
   application_name: Project
   location: #__CWD__
   environment_variables:
      - key: MOJO_MODE
        value: development
      - key: MOJO_LISTEN
        value: http://*:8889
database:
  type: sqlite
  dbfile: #__CWD__/app.db
  is_verbose: 1
   
models:
  - object: Namespace::Project
    many_to_many: 
     -  object: Namespace::User
        table: ProjectXManager
        my_column: Project_ID
        relationship_col: User_ID
        member: Managers
        primary_key: ID
    has_many:
     -  object: Namespace::Task
        key: Project_ID
        member: Tasks        
    table: Project
    columns:
     -  name: ID
        type: integer
        primary_key: 1
     -  name: name
        type: text
        constraints: "not null"
        to_string: 1  
     -  name: completion_date
        type: text    
        input_type: date

        

  - object: Namespace::Task
    table: Task
    columns:
     -  name: ID
        type: integer
        primary_key: 1
     -  name: name
        type: text
        constraints: "not null"
        to_string: 1  

     -  name: Project_ID
        type: integer
        constraints: 
        foreign_key: Namespace::Project
        member: Project

     -  name: User_ID
        type: integer
        constraints: 
        foreign_key: Namespace::User
        member: User



  - object: Namespace::User
    many_to_many:
     -  object: Namespace::Project
        table: ProjectXEmployee
        my_column: Employee_ID
        relationship_col: Project_ID
        member: Projects
        primary_key: ID
    table: User
    columns:
     -  name: ID
        type: integer
        primary_key: 1
        
 
     -  name: image
        type: text
        input_type: file
        display: |
            return "<img width='140' height='140' class='img-rounded' src='" . $object->get_image() . "'/>"; 
        
        
     -  name: login
        type: text
        constraints: "not null"
        to_string: 1

     -  name: password_hash
        type: text
        constraints: "not null"
        display: none      

     -  name: password_salt
        type: text
        constraints: "not null"
        display: none        

     -  name: Role_ID
        type: integer
        constraints: 
        foreign_key: Namespace::Role
        member: Role

    initial_values:
     - login: admin
       password_hash: 05aaab2856408bcc06db2fe28ac184db30fcbdfc
       password_salt: nelsonmandella1288
       Role_ID: 1 



  - object: Namespace::Role
    has_many:
     -  object: Namespace::User
        key: Role_ID
        member: Users  
    table: Role
    columns:
     -  name: ID
        type: integer
        primary_key: 1
     -  name: name
        type: text
        constraints: "not null"
        to_string: 1
        
    initial_values:
     - name: admin
     - name: anonymous
     - name: managers
     - name: users
     
authorization:
  login_path: /__ADMIN__/login
  login_controller: Zoe::AuthenticationController
  login_show_method: show_login
  login_do_method: do_login
  login_template: zoe/signin
  login_user_param: user
  login_password_param: password
  default_index: /__ADMIN__

  logout_path: /logout
  logout_controller: Zoe::AuthenticationController
  logout_do_method: logout



  user_session_key: user_id
  role_session_key: role

  methods:
    data_object: __DEFAULT__  
    
  config:
    routes:
      -  path: /__ADMIN__.*
         method: match_role
         http_method: any
         match_roles:
           - name: admin
      -  path: .*
         method: match_role
         http_method: any
         match_roles:
          - name: '*'
        
    data_object:
      auth_object: Namespace::User
      role_member: Role
      salt_member: password_salt
      password_member: password_hash
      user_name_member: login
      role_object: Namespace::Role
      admin_role: admin   
      role_column: Role_ID
      
      








     
 