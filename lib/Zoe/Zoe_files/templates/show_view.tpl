
% layout $layout;
% my %helper_options = %{ $helper_opts }; 

<h1>View #__OBJECTSHORTNAME__</h1>
<p>
%my $primary_key_value = $object->get_primary_key_value;
%my $url = url_for ("#__DELETELINK__", id=> $primary_key_value);
<form method='POST' action='<%= $url   %>' enctype="multipart/form-data" >

<button class="btn btn-danger" type='submit'> Delete </button>
</form>

</p>

<table class='table table-striped'>

<tbody> 
    %== get_rows_for_dataobject( object=>$object, resolve_relationships => 1 , %helper_options,prettyfy => 1);
</tbody>
	</table>

	

	% my %has_many_info = $object->get_has_many_info();
	% foreach my $member_name ( keys( %has_many_info ) ) {
	
	   <h3><%= $member_name %> </h3>
	   <table class='table table-striped'>

            <tbody> 
		
	       <%== get_rows_for_many(object=>$object, td_attributest=>'colspan="2" ', 
			     member_name =>$member_name , prettyfy => 1);
	       %>
	
	        </tbody>
	   </table>
	
	%}
	
	% my %many_info = $object->get_many_to_many_info();
	% foreach my $member_name ( keys( %many_info ) ) {
	
	   <h3><%= $member_name %> </h3>
	   <table class='table table-striped'>

            <tbody> 

	           <%== get_rows_for_many(object=>$object, td_attributest=>'colspan="2" ', 
			         member_name =>$member_name);
			     %>
	
		</tbody>
	</table>
	% }

