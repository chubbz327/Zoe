    #set routes
   
    $r->get('/#__URLPREFIX__#__OBJECTNAME__')->name('#__OBJECTNAME___show_all')
        ->to(namespace=>'#__CONTROLLER__' , action => 'show_all');

    #show create form
    $r->get('/#__URLPREFIX__#__OBJECTNAME__/create')->name('#__OBJECTNAME___show_create') 
            ->to(namespace=>'#__CONTROLLER__', action => 'show_create');

    #show a specific object; id in request param
    $r->get('/#__URLPREFIX__#__OBJECTNAME__/:id')->name('#__OBJECTNAME___show')
            ->to(namespace=>'#__CONTROLLER__', action => 'show');

    #show edit form for object; in in request param
    $r->get('/#__URLPREFIX__#__OBJECTNAME__/edit/:id')->name('#__OBJECTNAME___show_edit')
            ->to(namespace=>'#__CONTROLLER__', action => 'show_edit');

    #update object
    $r->post('/#__URLPREFIX__#__OBJECTNAME__/:id')->name('#__OBJECTNAME___update') 
			 ->to(namespace=>'#__CONTROLLER__', action => 'update');
			 
	#search
    $r->any('/#__URLPREFIX__#__OBJECTNAME___search')->name('#__OBJECTNAME___search') 
			 ->to(namespace=>'#__CONTROLLER__', action => 'search');		 
			 

    #create new object
    $r->post('/#__URLPREFIX__#__OBJECTNAME__/')->name('#__OBJECTNAME___create')
            ->to(namespace=>'#__CONTROLLER__' ,action => 'create');

    #delete object
    $r->post('/#__URLPREFIX__#__OBJECTNAME__/delete/:id')->name('#__OBJECTNAME___delete')
            ->to(namespace=>'#__CONTROLLER__', action => 'delete');
            
