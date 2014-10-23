serverstartup:
   application_name: Employee
   location: #__CWD__
   environment_variables:
      MOJO_MODE: development
      MOJO_LISTEN: http://*:8889
database:
  type: sqlite
  dbfile: #__CWD__/app.db
  is_verbose: 1
   
models:
  - object: Namespace::Project
    many_to_many: 
     -  object: Namespace::Employee
        table: ProjectXEmployee
        my_column: Project_ID
        relationship_col: Employee_ID
        member: Employees
        primary_key: ID
    table: Project
    columns:
     -  name: ID
        type: integer
        primary_key: 1
     -  name: name
        type: text
        constraints: "not null"
        to_string: 1  
     -  name: image
        type: text
        input_type: file
        constraints: "not null"
        display: |
            return "<img width='140' height='140' class='img-rounded' src='" . $object->get_image() . "'/>"; 
  
  - object: Namespace::Employee
    many_to_many:
     -  object: Namespace::Project
        table: ProjectXEmployee
        my_column: Employee_ID
        relationship_col: Project_ID
        member: Projects
        primary_key: ID
    table: Employee
    columns:
     -  name: ID
        type: integer
        primary_key: 1
     -  name: name
        type: text
        constraints: "not null"
        to_string: 1
     -  name: Department_ID
        type: integer
        constraints: 
        foreign_key: Namespace::Department
        member: Department
        
  - object: Namespace::Department
    has_many:
     -  object: Namespace::Employee
        key: Department_ID
        member: Employees
    table: Department
    columns:
     -  name: ID
        type: integer
        primary_key: 1
     -  name: name
        type: text
        constraints: "not null"
        to_string: 1

