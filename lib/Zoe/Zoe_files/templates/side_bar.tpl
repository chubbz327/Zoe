% my ($objects_ref, $url_prefix) = @_;


%%  if ( url_for() =~ /__RUNTIME__/ ) {

%%=     include 'fragments/runtime_sidebar';


%%} elsif ( url_for() =~ /__MANAGE__/ ) {

%%} elsif ( url_for() =~ /__DOCUMENTATION__/ ) {


          <li>
            <a href='/<%= $url_prefix . "__DOCUMENTATION__?module=" %>Zoe'>
              <i class='icon-chevron-right'></i> 
              Zoe Generator
            </a>
          </li>
          <li>
            <a href='/<%= $url_prefix . "__DOCUMENTATION__?module=" %>Zoe::DataObject'>
              <i class='icon-chevron-right'></i>
               Zoe::DataObject
            </a>
          </li>
          <li>
            <a href='/<%= $url_prefix . "__DOCUMENTATION__?module=" %>Zoe::Helpers'>
              <i class='icon-chevron-right'></i> 
              Zoe::Helpers 
            </a>
          </li>







          <li>
            <a href='/<%= $url_prefix . "__DOCUMENTATION__?module=" %>Zoe::Runtime::Authorization'>
              <i class='icon-chevron-right'></i> 
              Zoe::Runtime::Authorization
            </a>
          </li>
          
           <li>
            <a href='/<%= $url_prefix . "__DOCUMENTATION__?module=" %>Zoe::Runtime::ServerStartUp'>
              <i class='icon-chevron-right'></i> 
              Zoe::Runtime::ServerStartUp
            </a>
          </li>


           <li>
            <a href='/<%= $url_prefix . "__DOCUMENTATION__?module=" %>Zoe::Runtime::Database'>
              <i class='icon-chevron-right'></i>
              Zoe::Runtime::Database
            </a>
          </li>          
          
           <li>
            <a href='/<%= $url_prefix . "__DOCUMENTATION__?module=" %>Zoe::Runtime::Model'>
              <i class='icon-chevron-right'></i>
              Zoe::Runtime::Model
            </a>
          </li>


           <li>
            <a href='/<%= $url_prefix . "__DOCUMENTATION__?module=" %>Zoe::Runtime::ManyToMany'>
              <i class='icon-chevron-right'></i>
              Zoe::Runtime::ManyToMany
            </a>
          </li>       


           <li>
            <a href='/<%= $url_prefix . "__DOCUMENTATION__?module=" %>Zoe::Runtime::HasMany'>
              <i class='icon-chevron-right'></i>
              Zoe::Runtime::HasMany
            </a>
          </li>         

          
                     <li>
            <a href='/<%= $url_prefix . "__DOCUMENTATION__?module=" %>Zoe::Runtime::Column'>
              <i class='icon-chevron-right'></i>
              Zoe::Runtime::Column
            </a>
          </li>
%%  } else {

% foreach my $object ( @{$objects_ref} )
%  {
%       my $object_name = $object->{object};
%      # $object_name =~ s/.*\:\:(\w+)$/$1/gmx;
%	    my $object_route = $object->{object};
%       $object_route =~ s/\:\:/\//g;
        
%       $object_route = lc ($object_route);
%       my $route_name = $url_prefix . $object_route;
       
       
     
<li class='model_sidebar'>
	<a href='/<%= $route_name %>'>
		<i class='icon-chevron-right'></i>
		<%= $object_name %>
	</a>
</li>


% }


%% }

