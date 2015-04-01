



% layout $layout;
% my %helper_options = %{ $helper_opts }; 
% my %auth_object_info = $object->auth_object_info();
% my $password_member = $auth_object_info{password_member} ||0 ;
% my $salt_member = $auth_object_info{salt_member} || '';
% my @ignore = ($salt_member, $password_member); #empty if not auth object
% $object_action	= $type . $object_action;
% $object_action =~ s/\:\:/_/g;
% $object_action = lc ($object_action);
% my %linked_create = %{$object->get_linked_create()};

% my $url = url_for( $object_action );
% $url = url_for( $object_action , id=>$object->get_primary_key_value) if ($object->get_primary_key_value);
    
    <form   method='POST' action='<%= $url %>' 
            id='form_<%=$object->get_primary_key_value %>'
            enctype="multipart/form-data"
            class="form-horizontal" role="form">
            
            <h2><%= $type %> </h2>

    <div id ='stored_inputs' style="display: none;"></div>

    
        <fieldset>

%== get_inputs_for_dataobject( object=>$object, resolve_relationships => 1, prettyfy => 1, %helper_options, ignore => \@ignore, linked_create =>\%linked_create );

% # if authobject display 

% if ( $password_member ) {

<div class="form-group">
        
        <label class="col-sm-2 control-label" for="password">Password</label>
        <div class="col-sm-10">
            <input  type='password'  class='required form-control' 
              id="password" name="<%=$password_member %>" 
            size="25" value=""  minlength="1" class='form-control'  />
        </div>
</div>


<div class="form-group">
        <label class="col-sm-2 control-label" for="password_match">ReType Password</label>
        <div class="col-sm-10">
            <input  type='password'  class='required form-control'   
                    id="password_match" name="password_match" 
                    size="25" value=""  minlength="1"
            equalTo='#password' />
        </div>
</div>

%}

% my %info1 =  $object->get_many_to_many_info();
% my %info2 =  $object->get_has_many_info() ;
 
% my %many_info = (%info2, %info1);

% my %no_select = $object->get_no_select(); 

% foreach my $member_name ( keys( %many_info ) ) {
%   unless ($no_select{$member_name} )	{
        <div class="form-group">
		      
                 <label class="col-sm-2 control-label"for="<%= $member_name %>"><%= $member_name %></label>
                    <div class="col-sm-10">
                    <select name="<%=$member_name %>" multiple='multiple' class='form-control'>
        	           <%== get_options_for_many(object=>$object, td_attributest=>'colspan="2" ',
        			     member_name =>$member_name, label => $member_name);
        			     %>
    	           </select>
    	       
    	           </div><!--end input -->
    	        
    	 </div>      
	
% }
% if( defined ( $linked_create{$member_name} ) ){
%   my $linked_object = $linked_create{$member_name}->new();
%   my $linked_object_short_name = $linked_object->get_object_type;
%   $linked_object_short_name  =~ s/.*\:\:(\w+)$/$1/gmx;
	       <div>
		      <button type="button" class="btn btn-link"
			     id="new_<%=$linked_object_short_name%>_button"
			     onclick="toggle_add('#new_<%=$linked_object_short_name%>', 
				                    '<%=$linked_object_short_name%>', 
				                    '#new_<%=$linked_object_short_name%>_button'
				                     )">
		          New <%= $linked_object_short_name %> 
		      </button>
	       </div>
	       <div id='previously_added_<%=$linked_object_short_name%>'> </div>
	       
	       <div class='well' id="new_<%=$linked_object_short_name%>" style='display:none;'>
		      <%== get_inputs_for_dataobject( object=>$linked_object, resolve_relationships => 1,  prettyfy => 1,
		              exclude=>[$object->get_object_type], prefix=> "ADD_" . $linked_object_short_name . "_" ); %>
		              
%   my $to_string_name = $linked_object->get_to_string_member() || '0';
		      <button type="button" class="btn btn-default"
		          onclick="add_to_request_param(  '<%=$member_name%>', 'ADD_<%= $linked_object_short_name%>_', 
		                                          '<%=$linked_object_short_name%>', '<%= $to_string_name%>' 
		                                          )">
		          Add <%= $linked_object_short_name %>
		       </button>
            </div> <!-- well -->
% }
% }
        <p/>
         <div class="form-group">
    
            <div class="col-sm-offset-2 col-sm-10">
                <input  type='submit'  class='btn btn-success' value='Save'/>
            </div> 
         </div>
    </fieldset>
</div> <!-- formgroup -->
</form>


