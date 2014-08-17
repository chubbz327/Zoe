
% layout $layout;
% my %helper_options = %{ $helper_opts }; 



%my $url = url_for('#__URL__', id=>$object->get_primary_key_value);
    
    <form   method='POST' action='<%= $url %>' 
            id='form_<%=$object->get_primary_key_value %>'
            enctype="multipart/form-data"
            class="form-horizontal" role="form">
            
            <h2>#__OBJECTSHORTNAME__</h2>

    <div id ='stored_inputs' style="display: none;"></div>

    
        <fieldset>

%== get_inputs_for_dataobject( object=>$object, resolve_relationships => 1, prettyfy => 1, %helper_options );
% my %info1 =  $object->get_many_to_many_info();
% my %info2 =  $object->get_has_many_info() ;
 
% my %many_info = (%info2, %info1);

% my %no_select = $object->get_no_select(); 
% my %linked_create = %{$object->get_linked_create()};
% foreach my $member_name ( keys( %many_info ) ) {
%   unless ($no_select{$member_name} )	{
        <div class="form-group">
		      
                 <label class="col-sm-2 control-label"for="<%= $member_name %>"><%= $member_name %></label>
                    <div class="col-sm-10">
                    <select name="<%=$member_name %>" multiple='multiple' class='form-controlled'>
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
<script>
	//number of objects added to request params
	var id_inc = 1;
    //initialize jquery validator
    $("#form_<%= $object->get_primary_key_value %>").validate();
    /*
		Add the input values whose name contains prefix within div to an object
		assign object json string to input param
    */
    function add_to_request_param(request_param, prefix, object_name, to_string_name  ) {
		
		var to_string_val;
		var input_id = request_param + "_INC_" + id_inc;
		//get list of inputs
		var div_id = '#new_' + object_name;
		var previously_added_id = '#previously_added_' + object_name;
		var object = new Object();
		var is_valid = true;
		var file_input_id ='';
		/*
		  assign input values to object keys
		  check validity
		*/
		$(div_id + " :input").each ( function() {
			if (this.validity.valid === true) {
				var member_name = this.name.replace(prefix, '');
			
				var file_regex = /file/i;
				if ( file_regex.test(this.type)) {
					var member_name_attr_val = $('#' + this.id).attr('member_name');
					member_name = member_name_attr_val.replace(prefix, '');
					file_input_id = this.name;
					object[member_name] =  this.id;
					
					var clone = $('#' +this.id).clone();
					clone.attr({id: ''});
					var parent = $('#' +this.id).parent();
					$('#' +this.id).appendTo( $("#stored_inputs"));
					clone.attr({ name: member_name_attr_val });
					clone.appendTo( parent);
					
					console.log('Adding file input: ' + file_input_id);
				}else {
						object[member_name] = this.value;
				}
				if ( to_string_name != '0') {
						if( member_name == to_string_name) {
							to_string_val = this.value;
						}
				}else {
					to_string_val = id_inc;
				}
			}else {
				 
				console.log('input ' + this.id + ' failed validation; ERROR: ' + this.validationMessage)
				var parent = $('#' + this.id).parent();
				console.log(parent + 'PARENT');
				is_valid = false;
				//$("#form_<%= $object->get_primary_key_value %>").valid();
				$('#' + this.id ).valid();
			}
		}
		);
		if (! is_valid) {
				return;
		}
		//assign object values to hidden input
		console.log('Request param '+ request_param + ' = ' + JSON.stringify(object) );
		$('<input>').attr(
		{
				type: 'hidden',
				id: input_id,
				name: request_param,
				value: JSON.stringify(object),
		}).appendTo(div_id);
		$('<a>').attr({
				href: previously_added_id,
				id: 'a_' + input_id,
				data_file_input_id: file_input_id,
				onclick: "remove_from_request('"+input_id + "' , '" + 'a_' + input_id + " ' )"
		}).appendTo(previously_added_id);
		$('#a_' + input_id).html('Remove ' + to_string_val + '&nbsp;');
		//Clear inputs
		$(div_id + " :input").each ( function() {
				var input_obj = $('#' + this.id);
				if(  input_obj.attr('type') != 'hidden' ) {
				input_obj.val('');
				this.value = '';
				}
		});
		
		//Change the button from hide back to new
		var button_id = '#new_' + object_name + '_button';
		$(button_id).html('New ' + object_name);
		$(div_id).fadeToggle()
		id_inc++;
    }
    function remove_from_request (input_id, a_link_id) {
		var file_input = $('#' + a_link_id).attr('data_file_input_id');
		if (file_input.length > 0 ){
			$('#' + file_input).remove();
		}
		$('#' + input_id).remove();
		$('#' + a_link_id).remove();
    }
    function toggle_add(add_div_id, item_name, button_id ) {
		var button_text;
		if ( $(add_div_id).is(':visible') ) {
			button_text = "New " +  item_name;
		}else {
			button_text = "Hide " +  item_name ;
		}
		
		/*
			if file input set the id and the name so tha tth ediv can be hidden
		*/
		$(add_div_id + ' :input').each( function() {
			var file_match = /file/i;
			
			if ( (file_match.test(this.type)) && (! $.trim(this.value).length)  ) {
				$('#' + this.id).attr({member_name: this.name});
				this.id = this.name +id_inc;
				this.name = this.id;
			
			}
		
		}		
		);
		$(button_id).html(button_text);
		$(add_div_id).fadeToggle();
    }
  </script>
