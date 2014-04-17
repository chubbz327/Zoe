package  Zoe::Helpers;
  use strict;
use warnings;
use Data::Dumper;
use Mojo::Base 'Mojolicious::Plugin';
use Lingua::EN::Inflect qw ( PL );
use List::MoreUtils qw{any};
use Mojo::Util qw (xml_escape);
our $VERSION = '0.2';

use vars qw (
		%args	
		$controller 
		$object      
		$class       
		$hide_id_link 
		%column_info 
		$primary_key_value	
		$primary_key_name	
		$object_to_string	
		$type
		$tr_attributes
		$td_attributes
		$th_attributes
		@order
		@ignore
		$limit
		$offset
		$count
		$order_by
		$search
		@excluded_relationships
		$prefix
		$prettyfy
		$xml_escape
);
sub register {
    my ( $self, $app ) = @_;
    foreach my $name (
        qw( 	get_rows_for_dataobject_list
        get_rows_for_dataobject
        get_form_for_dataobject
		get_inputs_for_dataobject
		get_rows_for_many
		get_options_for_many
		get_tableheading
		get_pagination
        )
      )
    {
        my $method_name = '_' . $name;
        $app->helper(
            $name => sub {
                my $controller = shift;

		Zoe::Helpers->new()->$method_name(controller => $controller, @_);
            }
        );
    }
}
sub _prettyfy {
	my $self = shift;
	
	my $string = shift;
	return xml_escape ($string) unless $prettyfy;
	$string =~ s/_/ /g;
	return xml_escape(ucfirst($string));
		 
}

sub _set_global_values {
	my $self 	= shift;
	%args	= @_;
	$controller  = $args{controller};
    $object      = $args{object};
    $class       = $args{class} || "";
    $search 	 = $args{search};
    $prefix 	 = $args{prefix} || '';
    $prettyfy	 = $args{prettyfy} || 0;
    $xml_escape	 = $args{xml_escape} || 0;
    
    @excluded_relationships = ();
    @excluded_relationships =  @{ $args{exclude} } if (defined( $args{exclude}));
    
	$hide_id_link = $args{hide_id_link};
	$td_attributes	= $args{'td_attributes'} || '';
	$tr_attributes	= $args{'tr_attributes'} || '';
	$th_attributes  = $args{'th_attributes'} || '';
	$limit			= $args{'limit'} || 0;
	$offset			= $args{'offset'} || 0;
	$count			= $args{'count'} || 0;
	$order_by		= $args{'order_by'};
	@order = ();
	@ignore = ();
	@order     	= @{$args{'order'} } if (defined( $args{'order'}) );
	@ignore     	= @{$args{'ignore'} } if (defined( $args{'ignore'}) );
	
	%column_info 	= $object->get_column_info();
	
	
	$primary_key_value	= $object->get_primary_key_value() || '';
	$primary_key_name	= $object->get_primary_key_name();
	$object_to_string	= $object->to_string;

	print "ORDER\n" . Dumper @order ;
}
sub _get_route_name_for_object {
	my $self	 	= shift;
	my $object	 	= shift;
	my $append		= shift;
	my $route_name = $object->get_object_type();
    $route_name =~ s/.*::(\w+)$/$1/;
    $route_name .=  $append;
	$route_name	= lc($route_name);
	return $route_name;
}

sub _get_pagination {
    my $self = shift;
    
	$self->_set_global_values(@_);	 
	return "" unless ( $count > $limit);
	my $return_string = 
		q^ <div class="pagination"> <ul>^;
	
	my $next = $offset;
	$next = ($offset + $limit) if ( ( $offset + $limit ) < $count);
	my $prev = 0;
	if ( $offset - $limit > 0 ) {
		$prev = $offset - $limit;
	}
	
	my $prev_url = $controller->url_with->query([order_by => $order_by, offset => $prev, limit => $limit, search => $search]);
	my $next_url = $controller->url_with->query([order_by => $order_by, offset => $next, limit => $limit, search => $search]);
	$return_string .= 
		qq^<li><a href="$prev_url">Prev</a></li> ^;
	my $page_num = 1;	
	
	my $max = $count;
	if ( $max % $limit ) {
		$max += ( ( $max % $limit) - $limit ) * -1;
	}
	for (my $i=0; $i < $max -1; $i+=$limit ) {
		
		my $paged_url = $controller->url_with->query([order_by => $order_by, offset => $i, limit => $limit, search => $search]);
		$return_string .= 
		qq^<li><a href="$paged_url">$page_num</a></li> ^;
		$page_num++;
	
	}
	$return_string .= 
		qq^<li><a href="$next_url">Next</a></li> ^;
	$return_string .= 
		q^</ul></div>^;
		
		return $return_string;
}

sub _get_tableheading {
	my $self = shift;
	$self->_set_global_values(@_);
 
	my $return_string = qq^<tr $tr_attributes>^;
	my $pkey_asc = $controller->url_with->query([order_by => $object->get_primary_key_name ]);
	my $pkey_desc = $controller->url_with->query([order_by => "-" . $object->get_primary_key_name]);
	
	$return_string .= qq^<th $th_attributes >
								<a href='$pkey_asc'> 
										<i class='icon-chevron-up'></i>  
								</a>^ 
								. $self->_prettyfy (
										$object->get_display_as_for($object->get_primary_key_name)
								) .
								qq^
								<a href='$pkey_desc'> 
										<i class='icon-chevron-down'></i>  
								</a>
								</th>
	
	^;
		my @column_names;
	if (@order) {
        @column_names = @order;

   }else {
        @column_names = sort( keys ( %column_info) );
   }

	foreach my $column_name ( @column_names ) {
		next if any { $column_name eq $_ } @ignore;
		next if ( $object->get_primary_key_name eq $column_name );
		#ascending order
		my $url_asc = $controller->url_with->query([order_by => $column_name]);
	
		#descending order_by
		my $url_desc = $controller->url_with->query([order_by => "-" . $column_name]);
		#if foreign key get the member name else use the column name 
		my $member_name = ($object->get_member_for_column($column_name) || $column_name);
		
		#make the table heading
		$return_string .= qq^<th $th_attributes>
								<a href='$url_asc'> 
										<i class='icon-chevron-up'></i>  
								</a>^ . $self->_prettyfy ( $object->get_display_as_for($member_name) ). qq^ 
								<a href='$url_desc'> 
										<i class='icon-chevron-down'></i>  
								</a>
								</th> ^;
				
	}
	
	$return_string .= "</tr>";
	
	return $return_string;
		
}

sub _get_inputs_for_dataobject {
	my $self 	= shift;	
	$self->_set_global_values(@_);
	#get the name for  the named route
   my $return_string = "<input type='hidden'  id='$prefix$primary_key_name' name='$prefix$primary_key_name' value='$primary_key_value' />\n";
   
   my @column_names;
   if (@order) {
		@column_names = @order;
   
   }else {
		@column_names = sort( keys ( %column_info) );
   }
   
   foreach my $column_name ( @column_names )  {
		next if any { $column_name eq $_ } @ignore;		
        my $column_type = $column_info{$column_name};
        my $method_name = 'get_' . $column_name;
		my $input_class = $self->_get_class_for_input($object, $column_name);
        if (   ( $column_type eq 'FOREIGNKEY' )
            && ( defined( $args{resolve_relationships} ) ) )
        {
            my $fk_type	= $object->get_foreign_key_type($column_name);
            #next if matches excluded_relationships
            next if any { $_ eq $fk_type } @excluded_relationships;
			my $fk_member	= $object->get_member_for_column($column_name);
            my $fk_method =
              "get_" . $fk_member;
            my $fk_object = $object->$fk_method();
			my $fk_pkey	= 0;
		
			
			$fk_pkey = $fk_object->get_primary_key_value if ($fk_object);
			
            my @fk_objects =	$fk_type->find_all();
			$return_string .=  "<label for='$column_name'>$fk_member</label><em>*</em>\n" .
								"<select name='" . $prefix . $column_name . "' $input_class id='$prefix$primary_key_name' >\n";
            $return_string .= "<option value=''>\&nbsp; </option>\n";
			foreach my $fk (@fk_objects) {
				
				my $selected = '';
				$selected = 'selected="selected" ' if ($fk_pkey == $fk->get_primary_key_value() );
				my $fk_id = $fk->get_primary_key_value();
				my $fk_to_string = $fk->to_string();
				$return_string .= "<option value='$fk_id' $selected >$fk_to_string </option>\n";
			}	
			$return_string .="</select>";
        }
        else {
            #print columns unless primary key; already done
			
	    my $input_type 	= $self->_get_type_for_input(column=>$column_name, object=>$object);			
            my $value = $object->$method_name() || "";
            
			my $check_input = $self->_get_input_type(column=>$column_name, object=>$object);
			
			unless ( $object->get_primary_key_name eq $column_name ) {
				$return_string .= 
						qq^<p><label for="$column_name">^ .$self->_prettyfy ( $object->get_display_as_for($column_name) ) . qq^</label><em>*</em>^;
				if ($check_input eq 'textarea') {
					$return_string .=
						qq^<textarea $input_class id="$prefix$column_name" name="$prefix$column_name"  ^ .
						qq^> $value</textarea>\n^;
				
				
				} elsif( $check_input eq 'select') {
						$return_string .= 	"<select name='$column_name'> \n" .
											"<option> ... </option>" . 
											$object->get_select_options_for($column_name) . 
											" </select>";
						
				} elsif ($check_input eq 'radio' ){
						my $checked = '';
						$checked = 'checked="checked"' if ($object->$method_name() );
						
						$return_string .=
								qq^<input  $input_type $input_class id="$prefix$column_name" name="$prefix$column_name"^ . 
								qq^ $checked>\n^;
				
				}else {
					
				    $return_string .= 
				    qq^<input  $input_type $input_class id="$prefix$column_name" name="$prefix$column_name" ^ .
				    qq^size="25" value="$value"  minlength="2" /></p>	\n^;
				
				}
		    }
        }
    }
	return $return_string;
	

}

sub _get_input_type {
		my $self = shift;
		
    my %arg	= @_;
    
    my $object = $arg{object};
    my $column = $arg{column};
    
    my %column_info = $object->get_column_info();
    return $column_info{$column};
}


sub _get_type_for_input {
    my $self 	= shift;
    my %arg	= @_;
    
    my $object = $arg{object};
    my $column = $arg{column};
    
    my %column_info = $object->get_column_info();
    
    my $column_type = $column_info{$column};
    
    if ( $column_type =~ /^text$|^integer/mx) {
    	return "type='text' " ;
    } else {
	return "type='$column_type' ";
   }           
}

############################################
# Usage      : private??
# Purpose    : determines of input filed is requrired   
# Returns    : string : class='required' or empty string if not required
# Parameters : $object and the $column i.e column name
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
sub _get_class_for_input { 
 	my ( $self, $object, $column ) = @_;
	
	my %column_info = $object->get_column_info();
    
    my $column_type = $column_info{$column};
	
	#if input type is file and primary_key_value is not null this is an update so we do not have to have the 
	#file input present
	return  "" if ( (defined($object->get_primary_key_value) ) && ( $column_type =~ /file/mx ) );

	return "class='required' required " if $object->is_required_column($column);
	return "";
}

sub _get_rows_for_dataobject {
	my $self 	= shift;	
	$self->_set_global_values(@_);
	#get the name for  the named route
    my $route_name = $self->_get_route_name_for_object($object, '_show_edit');		
	my ($show_link, $return_string);
	$show_link =
			$controller->url_for( $route_name, id => $object->get_primary_key_value );
	##
	# if hide_id_link is set do not show the id field in the view only 
	# the action taken 
	if ( $hide_id_link ) {
		$return_string = "
			<tr $tr_attributes > <td $td_attributes >\&nbsp; </td> <td $td_attributes > <a href='$show_link'>
				Edit </a></td> </tr>";
	} else {		
		$return_string = "
			<tr $tr_attributes  > <td $td_attributes >$primary_key_name </td> <td $td_attributes > <a href='$show_link'>
				$primary_key_value </a></td> </tr>";
	}
   my @column_names;
   if (@order) {
		@column_names = @order;
   
   }else {
		@column_names = sort( keys ( %column_info) );
   }
   
   foreach my $column_name ( @column_names )  {
		next if any { $column_name eq $_ } @ignore;
        my $column_type = $column_info{$column_name};
        my $method_name = 'get_' . $column_name;

        if (   ( $column_type eq 'FOREIGNKEY' )
            && ( defined( $args{resolve_relationships} ) ) )
        {
            #my $fk_type	= $object->get_foreign_key_type();
            my $fk_method =
              "get_" . $object->get_member_for_column($column_name);
            my $fk_object = $object->$fk_method();
            my $fk_value = '';
            if ($fk_object) {
                $fk_value = $fk_object->to_string() || '';
            }
            if ($fk_object) {
				my $route_name	= $self->_get_route_name_for_object($fk_object, "_show") ;
				my $url = $controller->url_for( $route_name, id => $fk_object->get_primary_key_value );
				$return_string .= "<tr $tr_attributes > <td $td_attributes >$column_name</td> <td $td_attributes > <a href='$url'>$fk_value </a> </td> </tr>";
            } else {
				$return_string .= "<tr $tr_attributes > <td $td_attributes >" .  
				$self->_prettyfy ( $object->get_display_as_for($column_name) )
				."</td> <td $td_attributes > \&nbsp; </td> </tr>";
            }
            
        }
        else {
            #print columns unless primary key; already done
            
            my $display = $object->get_column_display($column_name);
            my $value = '';
            if ( $display ) {
		$value = eval $display;

	    } else {
            
		$value = $object->$method_name();
		$value = "" unless($value);
		$value = xml_escape($value);
            }
            $value =~ s/\n/<br>/g;
            $return_string .= "<tr $tr_attributes > <td $td_attributes > $column_name </td> <td $td_attributes > $value </td></tr>
			"
              unless ( $object->get_primary_key_name eq $column_name );
        }
    }
 
	
	return $return_string;
}

sub _get_rows_for_dataobject_list {
    my $self = shift;
    $self->_set_global_values(@_);
	
	#return string
    my $return_string     = "<tr $tr_attributes class='$class' id='$primary_key_value' >";

    #set the primary key as the first column
    #
    #get the name for  the named route
    my $route_name = $self->_get_route_name_for_object($object, '_show');
    my $show_link =
      $controller->url_for( $route_name, id => $object->get_primary_key_value );

   #my $show_link = $self->_get_url_path_for_data_object( $object, $controller);
    #####
    #$show_link .= '/' . $object->get_primary_key_value;
    if ( $hide_id_link ) {
		$return_string .= "<td $td_attributes > $primary_key_value </td> ";
    } else {
		$return_string .= "<td $td_attributes ><a href='$show_link'> $primary_key_value </a></td> ";
	}
	my @column_names;	
    if (@order) {
        @column_names = @order;

    }else {
        @column_names = sort( keys ( %column_info) );
    }




    foreach my $column_name ( @column_names ) {
		next if any { $column_name eq $_ } @ignore;
        my $column_type = $column_info{$column_name};
        my $method_name = 'get_' . $column_name;

        if (   ( $column_type eq 'FOREIGNKEY' )
            && ( defined( $args{resolve_relationships} ) ) )
        {
            #my $fk_type	= $object->get_foreign_key_type();
            my $fk_method =
              "get_" . $object->get_member_for_column($column_name);
            my $fk_object = $object->$fk_method();

            
            my $fk_value = '';
            if ($fk_object) {
                $fk_value = $fk_object->to_string() || '';
                
                my $route_name	= $self->_get_route_name_for_object($fk_object, "_show") ;
				my $url = $controller->url_for( $route_name, id => $fk_object->get_primary_key_value );
				$return_string .= " <td $td_attributes > <a href='$url'>$fk_value </a> </td> ";
				
            }else {
            $return_string .= "<td $td_attributes >" . $fk_value . '</td>';
            }
        }
        else {
            #print columns unless primary key; already done
            my $display = $object->get_column_display($column_name);
            my $value = '';
            if ( $display ) {
		$value = eval $display;

	    } else {
            
		$value = $object->$method_name();
		
            }
            $value = "" unless($value);
            $value = xml_escape($value) if ($xml_escape);
            $value =~ s/\n/<br>/g;
            $return_string .= "<td $td_attributes > $value </td>"
              unless ( $object->get_primary_key_name eq $column_name );
        }
    }
    $return_string .= "</tr>\n";
    return $return_string;
}

sub _get_rows_for_many {
	my $self = shift;
    $self->_set_global_values(@_);
	my $member_name 	= $args{member_name};
	my $label			= $args{label} || '&nbsp;';
	my $method_name		= "get_" . $member_name;
	my @many_objects	= $object->$method_name;
	
	my $return_string;
	$return_string .="<tr $tr_attributes><td $td_attributes>$label</td></tr>\n" 
		if ( defined($label) );
	foreach my $many_object ( @many_objects ) {
		my $many_string	= $many_object->to_string;
		my $route_name	= $self->_get_route_name_for_object($many_object, "_show");
		my $url = $controller->url_for( $route_name, id => $many_object->get_primary_key_value );
		$return_string .= "	<tr $tr_attributes class='$class'> 
								<td $td_attributes><a href ='$url'> $many_string</a></td> </tr>\n";
	}
	return $return_string;
}
sub _get_options_for_many {
	my $self = shift;
    $self->_set_global_values(@_);
	my $member_name 	= $args{member_name};
	my $label			= $args{label};
	my $method_name		= "get_" . $member_name;
	my @many_objects	= $object->$method_name;
	
	#print "MEMBERNAME $member_name \n";
	my $type = $object->get_type_for_many_member($member_name);
	print "TYPE $type MEMBER $member_name\n";
	my @all_many_objects = $type->find_all();
	
	my $return_string	="";
	foreach my $many_object ( @all_many_objects ) {
		my $many_string	= $many_object->to_string;
		my $fk_pkey		= $many_object->get_primary_key_value();
		my $selected	= '';
		
		#set the selected attribute
		if (  @many_objects ) { 
		
		$selected	= "selected='selected' "
			if ( any { $_->get_primary_key_value() == $fk_pkey} @many_objects);
			
		}
		$return_string .= "<option value='$fk_pkey' $selected >$many_string</option>\n";
	}
	return $return_string;
}


1;

__DATA__

=head1 NAME

Zoe::Helpers - Provides helper methods that genrate html for Zoee::DataObjects

=head1 VERSION

This documentation refers to ZOE::Helpers version 0.1

=head1 SYNOPSIS

		#Mojolicious::Plugin	
		$self->plugin('Zoe::Helpers');
		
		#Mojolicious::Lite
		plugin 'Zoe::Helpers';
		
=head1 Helper Argument Keys

Zoe::Helpers methods take the following arguments read from hash keys

=head2 object 

The Zoee::DataObject that the helper will work with (mandatory)

=head2 resolve_relationships

Boolean that determines whether foreign key values are replaced with the member designated as the to_string member or the foreign key object 

		 get_rows_for_dataobject_list( object=>$object, resolve_relationships => 1 );

=head2 td_attributes

Optional string containing attributes that will be added to TD tags generated by the helper

=head2 tr_attributes

Optional string containing attributes that will be added to TR tags generated by the helper	
	 
=head2 th_attributes

Optional string containing attributes that will be added to TH tags generated by the helper			 

=head2 order

Optional array ref containing column names in the order that they should be diplayed

=head2 order

Optional array ref containing column names   whose values should not be displayed


=head1 Helpers

=head2 get_tableheading 

Returns an html table heading for the specified Zoe::DataObject. The table columns are named for the Zoee::DataObject members

		%== get_tableheading( object => $object);

=head2 get_rows_for_dataobject_list

Returns the values of the Zoe::DataObjects' members are a HTML table row
		
		 %== get_rows_for_dataobject_list( object=>$object, resolve_relationships => 1 );

=head2 get_rows_for_dataobject

Returns a HTML table rows for Zoe::DataObject with the member name as the first column and the value as the second

		%== get_rows_for_dataobject( object=>$object, resolve_relationships => 1 );

=head2 get_rows_for_many

Returns the to_string value for all of the objects stored in the array corresponding to member_name.  Used to show the value of members classified as a MANY in a has_Many or many_to_many relationship
		
		 <%== get_rows_for_many(object=>$object, td_attributest=>'colspan="2" ',
                        member_name =>$member_name );
        %>

=head2 get_inputs_for_dataobject

Returns HTML form fields for the specified data object.  Foreign key inputs are shown as selects fields.

		%== get_inputs_for_dataobject( object=>$object, resolve_relationships => 1 );

=head2 get_options_for_many 

Returns HTML select options for the specified MANY_TO_MANY or HAS_MANY member 

		% foreach my $member_name ( keys( %many_info ) ) {
        <label for="<%= $member_name %> "><%= $member_name %></label><em>*</em>

        <select name="<%=$member_name %>" multiple='multiple'>
        <%== get_options_for_many(object=>$object, td_attributest=>'colspan="2" ',
                        member_name =>$member_name, label => $member_name);
                        %>


=head2 get_pagination 

Returns pagaination links for current page request

		%== get_pagination( object => $object, limit => $limit, offset => $offset, count=>$count, order_by => $order_by );

=head1 Author

	dinnibartholomew@gmail.com



		