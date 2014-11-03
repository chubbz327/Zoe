package Zoe::ZoeController;

use Mojo::Base 'Mojolicious::Controller';
use FindBin;
use JSON::Parse 'json_to_perl';
use Data::Dumper;
use Digest::SHA1 qw(sha1_hex);
use Data::Dumper;
use Mojo::Exception;

use Mojo::Util qw(slurp unindent url_escape);
use Pod::Simple::XHTML 3.09;
use Pod::Simple::Search;


BEGIN { unshift @INC, "$FindBin::Bin/../" }
use Data::GUID;

my $layout = 'zoe';
sub show_documentation {
	my $self    = shift;
	my $module = $self->param('module') || 'Zoe';
	my $path
    = Pod::Simple::Search->new->find($module, map { $_, "$_/pods" } @INC);
  return $self->redirect_to("https://metacpan.org/pod/$module")
    unless $path && -r $path; 
    my $src = slurp $path;
    my $doc =  $self->pod_to_html($src);
	return $self->render(text => "<div id='perldoc'> $doc</div>", layout => $layout);

}
sub delete {
    my $self    = shift;
    my %args    = @_;
    my $type    = $args{type};
    my $message = $args{message};
    my $url     = $args{url};

    my $id     = $self->param('id');
    my $object = $type->find($id);

    $url = $self->_get_success($object) unless ($url);
    $object->delete();
    $self->flash( message => $message );
     
    $self->redirect_to($url);
    return;
}

sub _get_short_name {
    my $self = shift;
    my $name = shift;
    $name =~ s/.*\:\:(\w+)$/$1/gmx;
    return $name;
}

sub log_not_authorized {
    my $self = shift;

    #get client request info
    my $request_env = Dumper $self->req->env;
    my $log         = $self->get_logger('secure');
    my @params      = $self->param();
    my %param_values;
    
    foreach my $name (@params) {
        $param_values{$name} = $self->param($name);
    }
    $log->error( __PACKAGE__
          . " Client IP: "
          . $self->tx->remote_address . "\nENV"
          . $request_env
          . "\nPARAMS:"
          . Dumper %param_values );
    my $res = $self->tx->res;
    $res->code(401);
    $self->render( template => 'not_authorized' );
    #say $res->to_string;

    #get
}

sub auth_create {
    my $self          = shift;
    my $object        = shift;
    my $salt          = Data::GUID->new()->as_string;
    
    
    my $auth_config   = $self->get_auth_config();
    my $password_param = $auth_config->{login_password_param};
    my $password      = $self->param($password_param);
    my $password_hash = sha1_hex( $salt . $password );
    
    my %auth_info     = %{ $auth_config->{config}->{data_object} };

    my ( $salt_member, $password_member ) =
      ( $auth_info{salt_member}, $auth_info{password_member} );
    $object->{$password_member} = $password_hash;
    $object->{$salt_member}     = $salt;

    if ( $self->param('user_session_member') ) {
        my $user_session_member = $self->param('user_session_member');
        
        $self->session($auth_config->{user_session_key} => $object->{$user_session_member});
        
     }
    return $object;

}

sub create {
    my $self    = shift;
    my %args    = @_;
    my $type    = $args{type};
    my $message = $args{message};
    my $object  = $type->new;
    print Dumper $object;

    my $url = ( $args{url} || $self->_get_success($object) );

    $object = $self->_set_values_from_request_param($object);
    if ( $object->is_auth_object() ) {
        $object = $self->auth_create($object);
    }
    $object->save();

    $self->flash( message => $message );

    $self->redirect_to($url);
}

sub _check_is_admin_or_self {
    my $self         = shift;
    my $object       = shift;
    my $auth_config  = $self->get_auth_config();
    my %auth_info    = %{ $auth_config->{config}->{data_object} };
    my $object_id    = $object->get_primary_key_value();
    my $current_role = $self->session( $auth_config->{role_session_key} ) || 0;
    my $current_user_id = $self->session( $auth_config->{user_session_key} )
      || 0;
    my $admin_role = $auth_info{admin_role};

    return 1 if ( $admin_role eq '*' );

    return 1 if ( $admin_role eq $current_role );

    print "OBJECT ID $object_id == $current_user_id\n\n";
    return 1 if ( $object_id == $current_user_id );
    return 0;
}

sub auth_update {
    my $self   = shift;
    my $object = shift;

    my $auth_config = $self->get_auth_config();
    my %auth_info   = %{ $auth_config->{config}->{data_object} };
    my ( $salt_member, $password_member ) =
      ( $auth_info{salt_member}, $auth_info{password_member} );

    #if password is not being updated just return
    my $password = $self->param('password');

    return $object unless ($password);

   #make sure current user has rights to edit user or redirect_to not authorized

    #get current user

    my $current_user;
    if ( $self->session( $auth_config->{user_session_key} ) ) {
        my $id = $self->session( $auth_config->{user_session_key} ) || 0;
        $current_user = $object->find($id);
    }

    my $current_salt = $current_user->{$salt_member} || '';
    my $old_password = $self->param('old_password')  || '';
    my $old_password_hash = sha1_hex( $current_salt . $old_password );

    #get the current role
    my $role_name = '';
    if ( $self->session( $auth_config->{role_session_key} ) ) {
        $role_name = $self->session( $auth_config->{role_session_key} ) || 0;
    }

    # if admin or if admin_role == *
    my $admin_role = $auth_info{admin_role};
    if (   ( $admin_role eq '*' )
        || ( $role_name eq $admin_role )
        || ( $current_user->get_password_hash eq $old_password_hash ) )
    {
        my $salt          = Data::GUID->new()->as_string;
        my $password_hash = sha1_hex( $salt . $password );

        $object->{$password_member} = $password_hash;
        $object->{$salt_member}     = $salt;
        return $object;
    }

    die Mojo::Exception->new('__BAD_CURRENT_PASSWORD__');
}

sub update {
    my $self    = shift;
    my %args    = @_;
    my $type    = $args{type};
    my $message = $args{message};
    my $id      = $self->param('id');
    my $object  = $type->find($id);
    my $url     = ( $args{url} || $self->_get_success($object) );

    $object = $self->_set_values_from_request_param($object);
    my $update_object;
    if ( $object->is_auth_object() ) {

        #check if user is authorized to update
        my $authorized = $self->_check_is_admin_or_self($object);
        unless ($authorized) {
            my $url = $self->url_for('__NOTAUTHORIZED__')->query(
                [
                    object_id => $object->get_primary_key_value(),
                    path      => $self->url_for()
                ]
            );

            $self->redirect_to($url);
            return;
        }
        try {
            $update_object = $self->auth_update($object);
            $object        = $update_object;

            $object->save;
            $self->redirect_to($url);

        }
        catch {

            #bad current password_hash
            my $redirect_to = $type;
            $redirect_to =~ s/.*\:\:(\w+)$/$1/mx;
            $redirect_to = lc($redirect_to);
            $redirect_to .= '_show_edit';
            my $url = $self->url_for($redirect_to)->query(
                [
                    id        => $id,
                    error_msg => 'Bad current password'
                ]
            );
            $self->redirect_to($url);
        };

    }
    else {
        $object->save;
        $self->redirect_to($url);
    }

    return;
}

sub show_all {
    my $self        = shift;
    my %args        = @_;
    my $type        = $args{type};
    my $template    = $args{template};
    my $limit       = $args{limit};
    
    my $where       = $args{where} || {};
    my $object      = $type->new;
    my $helper_opts = $args{helper_opts} || {};

    my $order    = $self->param('order_by');
    my $offset   = $self->param('offset') || 0;
    my $order_by = [];
    if ($order) {
        $order_by = [$order];
    }
    my $count = scalar( $type->find_all(where=>$where) );
    my @all =
      $type->find_all( order => $order_by, limit => $limit, offset => $offset, where=>$where );

    my $search;

    $layout = $args{layout} || $layout;

    $self->render(
        search      => $search,
        object      => $object,
        limit       => $limit,
        count       => $count,
        offset      => $offset,
        order_by    => $order,
        all         => \@all,
        template    => $template,
        helper_opts => $helper_opts,
        layout      => $layout,
        type		=> $type,
    );
}

sub show {
    my $self        = shift;
    my %args        = @_;
    my $type        = $args{type};
    my $template    = $args{template};
    my $helper_opts = $args{helper_opts} || {};
    my $id          = $self->param('id');

    my $object = $type->find($id);
    $layout = $args{layout} || $layout;

    $self->render(
        object      => $object,
        template    => $template,
        helper_opts => $helper_opts,
        layout      => $layout,
        type 		=> $type,
    );
}

sub show_create_edit {
    my $self      = shift;
    my %args      = @_;
    my $type      = $args{type};
    my $template  = $args{template};
    my $object_action = $args{object_action};
    my $id        = $self->param('id');
    my $message   = $self->param('message') || '';
    my $error_msg = $self->param('error_msg') || '';
    my $object    = $type->find($id) || $type->new;
    


    my $helper_opts = $args{helper_opts} || {};

    $layout = $args{layout} || $layout;
    $self->render(
        object      => $object,
        template    => $template,
        helper_opts => $helper_opts,
        layout      => $layout,
        message     => $message,
        error_msg   => $error_msg,
        type 		=> $type,
        object_action => $object_action,
    );

}


sub search {
    my $self        = shift;
    my %args        = @_;
    my $type        = $args{type};
    my $template    = $args{template};
    my $limit       = $args{limit};
    my $where       = $args{where} || {};
    my $object      = $type->new;
    my $helper_opts = $args{helper_opts} || {};    #options to the helper
    my @args        = () ;
    
    if ( $args{args} ) {
        @args = @{ $args{args} };
    
    }

    my @columns = $type->get_searchable_columns();
    my $search  = $self->param('search');
    my $order   = $self->param('order_by');

    my $offset = $self->param('offset') || 0;
    my $order_by = [];
    if ($order) {
        $order_by = [$order];
    }

    my $count =
      scalar( $object->search( columns => \@columns, search => $search, where=>$where ) );
    my @all = $object->search(
        columns => \@columns,
        search  => $search,
        order   => $order_by,
        limit   => $limit,
        offset  => $offset,
        where=>$where
    );

    $layout = $args{layout} || $layout;
    if (@args) {
        $self->render(
            @_,
            object      => $object,
            limit       => $limit,
            count       => $count,
            offset      => $offset,
            order_by    => $order,
            all         => \@all,
            search      => $search,
            template    => $template,
            helper_opts => $helper_opts,
            layout      => $layout,
            @args
        );
    } else {
        $self->render(
            @_,
            object      => $object,
            limit       => $limit,
            count       => $count,
            offset      => $offset,
            order_by    => $order,
            all         => \@all,
            search      => $search,
            template    => $template,
            helper_opts => $helper_opts,
            layout      => $layout,
           
        );
        
   }

}

sub _get_success {
    my $self         = shift;
    my $object       = shift;
    my $success_path = lc( $object->get_object_type );
    $success_path =~ s/\:\:/_/gmx;
    $success_path .= '_show_all';
    
    print Dumper $success_path;
    
    print "SUCESSPATH\n\n";
    my $url = $self->url_for($success_path);
    return $url;
}

sub _get_upload {
    my $self   = shift;
    my $object = shift;
    my $column = shift;

    my $uploaded_file = $self->param($column);
    return 0 unless ( $uploaded_file->size );
    my $filename      = $uploaded_file->filename;
    my $random_string = Data::GUID->new()->as_string;

    my $path =
      $object->get_upload_path() . '/' . $random_string . '__' . $filename;
    my $public_path =
        $object->get_public_upload_path() . '/'
      . $random_string . '__'
      . $filename;

    $uploaded_file->move_to($path);
    return $public_path;
}

sub _set_values_from_request_param {

    my ( $self, $object ) = @_;
    my $pkey_name   = $object->get_primary_key_name();
    my @columns     = $object->get_column_names();
    my %column_info = $object->get_column_info();
    my $log         = $self->get_logger('debug');

    #print Dumper ( $self->req->params->to_hash );

    foreach my $column (@columns) {
        my $input_type = $column_info{$column};
        my $method     = "set_$column";
        my $get_method = "get_$column";
        next if ( $column eq $pkey_name );

        if ( $input_type eq 'file' ) {

            #my $uploaded_file   = $self->param($column);
            #see if file to be uploaded is specified
            my $public_path = $self->_get_upload( $object, $column );
            if ($public_path) {

                $object->$method($public_path);

            }

        }
        else {

            my $value = $self->param($column);
            $object->$method($value) if ($value);
        }
    }

    my @many_to_many_members = $object->get_many_to_many_member_names();
    my @has_many_members     = $object->get_has_many_member_names();
    my @members              = ( @has_many_members, @many_to_many_members );

    foreach my $member_name (@members) {

        my $method  = 'set_' . $member_name;
        my $type    = $object->get_type_for_many_member($member_name);
        my @id_list = $self->param($member_name);
        
        $log->debug("member_name $member_name" . Dumper @id_list);
        my @object_list;

        foreach my $id (@id_list) {
        	#undef value was being added to @id_list; weird;
			next unless $id;
			
            if ( $id =~ /^\d+$/ ) {    #object was selected from drop dwon
                my $many_object = $type->find($id);

                push( @object_list, $many_object );
            }
            else {                     #new object
                my $type = $object->get_type_for_many_member($member_name);
                my %rel_column_info = $type->new()->get_column_info();

                #id is a json string containing object values
                my $values = json_to_perl($id);
                foreach my $rel_column ( keys %{$values} ) {
                    my $rel_input_type = $rel_column_info{$rel_column};
                    next unless $rel_input_type;    # ignore empty entry json
                    print "$rel_input_type $rel_column\n\n ";
                    if ( $rel_input_type eq 'file' ) {
                        my $rel_public_path =
                          $self->_get_upload( $type->new(),
                            $values->{$rel_column} );
                        $values->{$rel_column} = $rel_public_path
                          if ($rel_public_path);
                    }

                }

                my $many_object = $type->new($values);
                $many_object->{ $many_object->get_primary_key_name() } = undef;

    #objects that are part of a many to many relationship must be saved prior to
    #the related object
                my %many_object_info = $object->get_many_to_many_info;
                $many_object->save() if ( $many_object_info{$member_name} );
                push( @object_list, $many_object );

            }
        }
        $object->$method( \@object_list ) if ( scalar(@object_list) );

    }

    return $object;
}
1;
