- method: post
  path: #__URLPREFIX____MANAGE__/generate/
  name: __MANAGEGENERATE__
  controller: Zoe::RuntimeController
  action: generate


- method: post
  path: #__URLPREFIX____MANAGE__/restart_app
  name: __MANAGERESTARTAPP__
  controller: Zoe::RuntimeController
  action: restart_app

- method: get
  path: #__URLPREFIX____MANAGE__/
  name: __SHOWMANAGE__
  controller: Zoe::RuntimeController
  action: show_manage

- method: post
  path: #__URLPREFIX____SAVEALLMODELS__/
  name: __SAVEALLMODELS__
  controller: Zoe::RuntimeController
  action: save_all_models
  
- method: get
  path: #__URLPREFIX____RUNTIME__/
  name: __SHOW_RUNTIME__
  controller: Zoe::RuntimeController
  action: show_runtime  

- method: get
  path: #__URLPREFIX____RUNTIME__/:key
  name: __SHOW_RUNTIME_KEY__
  controller: Zoe::RuntimeController
  action: show_runtime  
  
- method: post
  path: #__URLPREFIX____RUNTIME__/
  name: __SAVE_RUNTIME__
  controller: Zoe::RuntimeController
  action: save_runtime  
  
- method: get
  path: #__URLPREFIX____DOCUMENTATION__/
  name: __SHOW_DOCUMENTATION__
  controller: Zoe::ZoeController
  action: show_documentation   