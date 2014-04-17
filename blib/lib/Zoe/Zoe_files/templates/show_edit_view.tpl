 
% layout $layout;
% my %helper_options = %{ $helper_opts }; 

<h1>Update  #__OBJECTSHORTNAME__</h1>



%my $url = url_for('#__UPDATEURL__', id=>$object->get_primary_key_value);
<form method='POST' action='<%= $url %>' id='form_<%=$object->get_primary_key_value %>' enctype="multipart/form-data">
%== get_inputs_for_dataobject( object=>$object, resolve_relationships => 1 ,  %helper_options);

% my %many_info = $object->get_many_to_many_info();
	% foreach my $member_name ( keys( %many_info ) ) {
	
	<label for="<%= $member_name %> "><%= $member_name %></label><em>*</em>
	
	<select name="<%=$member_name %>" multiple='multiple'>
	<%== get_options_for_many(object=>$object, td_attributest=>'colspan="2" ',  prettyfy => 1,
			member_name =>$member_name, label => $member_name);
			%>
	</select>
	%}
	
% %many_info	= $object->get_has_many_info();
	% foreach my $member_name ( keys( %many_info ) ) {
	<label for="<%= $member_name %> "><%= $member_name %></label><em>*</em>
	
	<select name="<%=$member_name %>" multiple='multiple'>
	<%== get_options_for_many(object=>$object, td_attributest=>'colspan="2" ', prettyfy => 1,
			member_name =>$member_name, label => $member_name);
			%>
	</select>
	%}
<br/>
<input type='submit' value='Update' class='btn btn-success' />
</form>

  <script>
  
    $("#form_<%= $object->get_primary_key_value %>").validate();

  </script>
