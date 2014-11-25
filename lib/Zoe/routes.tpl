- method: get
  path: #__URLPREFIX__#__OBJECTROUTE__
  name: #__OBJECTNAME___show_all
  controller: Zoe::ZoeController
  action: show_all
  model: #__OBJECTTYPE__


  
- method: get
  path: #__URLPREFIX__#__OBJECTROUTE__/create
  name: #__OBJECTNAME___show_create
  controller: Zoe::ZoeController
  action: show_create
  model: #__OBJECTTYPE__
  options:
	     __OBJECT_ACTION__: _create	  
     
- method: get
  path: #__URLPREFIX__#__OBJECTROUTE__/:id
  name: #__OBJECTNAME___show
  controller: Zoe::ZoeController
  action: show  
  model: #__OBJECTTYPE__

- method: get
  path: #__URLPREFIX__#__OBJECTROUTE__/edit/:id
  name: #__OBJECTNAME___show_edit
  controller: Zoe::ZoeController
  action: show_edit
  model: #__OBJECTTYPE__
  options:
     __OBJECT_ACTION__: _update	  

- method: post
  path: #__URLPREFIX__#__OBJECTROUTE__/:id
  name: #__OBJECTNAME___update
  controller: Zoe::ZoeController
  action: update 
  model: #__OBJECTTYPE__
  options:
	     __OBJECT_ACTION__: _update	  

- method: any
  path: #__URLPREFIX__#__OBJECTROUTE___search
  name: #__OBJECTNAME___search
  controller: Zoe::ZoeController
  action: search 
  model: #__OBJECTTYPE__
  
  
- method: post
  path: #__URLPREFIX__#__OBJECTROUTE__
  name: #__OBJECTNAME___create
  controller: Zoe::ZoeController
  action: create  
  model: #__OBJECTTYPE__
  options:
	     __OBJECT_ACTION__: _create	  
     
- method: post
  path: #__URLPREFIX__#__OBJECTROUTE__/delete/:id
  name: #__OBJECTNAME___delete
  controller: Zoe::ZoeController
  action: delete 
  model: #__OBJECTTYPE__

