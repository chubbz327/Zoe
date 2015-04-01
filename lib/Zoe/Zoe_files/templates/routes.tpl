- method: get
  path: #__URLPREFIX__#__OBJECTROUTE__
  name: #__OBJECTNAME___show_all
  controller: #__CONTROLLER__
  action: show_all
  type: #__OBJECTTYPE__
  
- method: get
  path: #__URLPREFIX__#__OBJECTROUTE__/create
  name: #__OBJECTNAME___show_create
  controller: #__CONTROLLER__
  action: show_create
  type: #__OBJECTTYPE__
 
- method: get
  path: #__URLPREFIX__#__OBJECTROUTE__/:id
  name: #__OBJECTNAME___show
  controller: #__CONTROLLER__
  action: show  
  type: #__OBJECTTYPE__

- method: get
  path: #__URLPREFIX__#__OBJECTROUTE__/edit/:id
  name: #__OBJECTNAME___show_edit
  controller: #__CONTROLLER__
  action: show_edit
  type: #__OBJECTTYPE__

- method: post
  path: #__URLPREFIX__#__OBJECTROUTE__/:id
  name: #__OBJECTNAME___update
  controller: #__CONTROLLER__
  action: update 
  type: #__OBJECTTYPE__

- method: any
  path: #__URLPREFIX__#__OBJECTROUTE___search
  name: #__OBJECTNAME___search
  controller: #__CONTROLLER__
  action: search 
  type: #__OBJECTTYPE__

- method: post
  path: #__URLPREFIX__#__OBJECTROUTE__
  name: #__OBJECTNAME___create
  controller: #__CONTROLLER__
  action: create  
  type: #__OBJECTTYPE__
     
- method: post
  path: #__URLPREFIX__#__OBJECTROUTE__/delete/:id
  name: #__OBJECTNAME___delete
  controller: #__CONTROLLER__
  action: delete 
  type: #__OBJECTTYPE__

- method: any
  path: #__URLPREFIX__#__OBJECTROUTE___save_all
  name: #__OBJECTNAME___save_all
  controller: #__CONTROLLER__
  action: save_all 
  type: #__OBJECTTYPE__


