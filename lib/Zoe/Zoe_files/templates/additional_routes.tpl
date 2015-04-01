- method: get
  path: #__URLPREFIX____RUNTIME__/
  name: __SHOW_RUNTIME__
  controller: Zoe::RuntimeController
  action: show  

- method: get
  path: #__URLPREFIX____RUNTIME__/:key
  name: __SHOW_RUNTIME_KEY__
  controller: Zoe::RuntimeController
  action: show  
  
- method: post
  path: #__URLPREFIX____RUNTIME__/
  name: __SAVE_RUNTIME__
  controller: Zoe::RuntimeController
  action: save  
  
- method: get
  path: #__URLPREFIX____DOCUMENTATION__/
  name: __SHOW_DOCUMENTATION__
  controller: Zoe::ZoeController
  action: show_documentation   