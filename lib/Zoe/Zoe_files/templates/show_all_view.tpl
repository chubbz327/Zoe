
% layout $layout;

% my %helper_options = %{ $helper_opts }; 



<h1>#__OBJECTNAMEPLURAL__</h1>
<p>
<a  href = '<%=url_for ("#__CREATELINK__") %>' class="btn btn-primary">Create New</a> 

</p>
%my $search_value = '';
%if (defined ($search)) {
%$search_value = 'for search: ' . $search; 
%}


<div>
%== get_pagination( object => $object, limit => $limit, offset => $offset, count=>$count, order_by => $order_by, search => $search );
<br>
<%= $count  %> #__OBJECTNAMEPLURAL__ returned <%= $search_value %><br>

<form method='POST' action='<%= url_for("#__SEARCHURL__") %>' id='form_search'
        enctype="multipart/form-data">
        
 Search: <input type='text' name='search' size='20' /> &nbsp; <input type='submit' value='search' class='btn btn-info' />
 
 </form>


<form 
</div>
<table class='table table-striped'>
<thead>
%== get_tableheading( object => $object, %helper_options, prettyfy => 1);
</thead>

<tbody>

% foreach my $object ( @{$all} ) {
    %== get_rows_for_dataobject_list( object=>$object, resolve_relationships => 1 ,  %helper_options, prettyfy => 1);
	
%}
</tbody>
</table> 
