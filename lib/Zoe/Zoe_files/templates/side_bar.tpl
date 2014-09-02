% my ($objects_ref, $url_prefix) = @_;


%%  if ( url_for() =~ /__RUNTIME__/ ) {

%%=     include 'fragments/runtime_sidebar';

%%  } else {

% foreach my $object ( @{$objects_ref} )
%  {
%       my $object_name = $object->{object};
%       $object_name =~ s/.*\:\:(\w+)$/$1/gmx;
%       my $route_name = $url_prefix . $object_name;
%       $route_name = lc($route_name);
       
       
     
<li class='model_sidebar'><a href='/<%= $route_name %>'><i class='icon-chevron-right'></i> <%= $object_name %></a></li>


% }

%% }

