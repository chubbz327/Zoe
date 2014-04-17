 
% layout $layout;
% my %helper_options = %{ $helper_opts }; 

<h1>Update  #__OBJECTSHORTNAME__</h1>

% my $password_member = '#__PASSWORDMEMBER__';
% my $salt_member = '#__SALTMEMBER__';

%my $url = url_for('#__UPDATEURL__', id=>$object->get_primary_key_value);
<form method='POST' action='<%= $url %>' id='form_<%=$object->get_primary_key_value %>' enctype="multipart/form-data">

% my @ignore = ($salt_member, $password_member);
%== get_inputs_for_dataobject( object=>$object, resolve_relationships => 1, prettyfy => 1, %helper_options, ignore=>\@ignore );

<p>
		<label for="password">Current Password</label>
		<em>*</em>
		<input  type='password'     id="old_password" name="old_password" 
		size="25" value=""  minlength="1" />
</p>

<p>
		<label for="password">New Password</label>
		<em>*</em>
		<input  type='password'     id="password" name="password" 
		size="25" value=""  minlength="1" />
</p>


<p>
		<label for="password_match">ReType New Password</label>
		<em>*</em>
		<input  type='password'    
				id="password_match" name="password_match" 
				size="25" value=""  minlength="1" 
		equalTo='#password' />
</p>


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
