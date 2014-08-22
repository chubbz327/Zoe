- method: get
  path: #__URLPREFIX__#__OBJECTNAME__
  name: #__OBJECTNAME___show_all
  controller: #__CONTROLLER__
  action: show_all
  
- method: get
  path: #__URLPREFIX__#__OBJECTNAME__/create
  name: #__OBJECTNAME___show_create
  controller: #__CONTROLLER__
  action: show_create
 
- method: get
  path: #__URLPREFIX__#__OBJECTNAME__/:id
  name: #__OBJECTNAME___show
  controller: #__CONTROLLER__
  action: show  

- method: get
  path: #__URLPREFIX__#__OBJECTNAME__/edit/:id
  name: #__OBJECTNAME___show_edit
  controller: #__CONTROLLER__
  action: show_edit

- method: post
  path: #__URLPREFIX__#__OBJECTNAME__/:id
  name: #__OBJECTNAME___update
  controller: #__CONTROLLER__
  action: update 

- method: any
  path: #__URLPREFIX__#__OBJECTNAME___search
  name: #__OBJECTNAME___search
  controller: #__CONTROLLER__
  action: search 

- method: post
  path: #__URLPREFIX__#__OBJECTNAME__
  name: #__OBJECTNAME___create
  controller: #__CONTROLLER__
  action: create  
     
- method: post
  path: #__URLPREFIX__#__OBJECTNAME__/delete/:id
  name: #__OBJECTNAME___delete
  controller: #__CONTROLLER__
  action: delete 

