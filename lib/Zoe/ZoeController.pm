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
use Path::Class;
use TryCatch;
my $layout = 'zoe';

sub save_all_models
{
    my $self    = shift;
    my %args    = @_;
    my $runtime = $self->get_runtime();
    my $models  = $runtime->{models};
    my $return  = {};
    foreach my $model ( @{$models} )
    {
        my $type = $model->{object};
        my @all  = $type->find_all();

        $return->{$type} = \@all;
    }
    my $time      = time();
    my $file_name = 'backup_' . 'all_models_' . $time . '.yaml';
    my $save_file = file( $self->get_config_dir(), $file_name );
    if ( YAML::XS::DumpFile( $save_file, $return ) )
    {
        return
          $self->render(
                         json => {
                                   success   => $time,
                                   file_name => $save_file,
                                   msg       => "$save_file saved",
                         }
          );
    } else
    {
        $self->log(" YAML save error  $save_file: $!");
        return
          $self->render(
                         json => {
                                   success => 0,
                                   error   => "YAML save error  $save_file: $!",
                         }
          );
    }
}

sub save_all
{
    my $self = shift;
    my %args = @_;
    my $type = my $__TYPE__ =
      $args{type} || $self->param('__TYPE__') || $self->stash('__TYPE__');
    eval "use $type";

    my @all    = $type->find_all();
    my $return = {};

    $return->{$type} = \@all;

    my $file_name = $type;
    $file_name = lc($file_name);
    $file_name =~ s/\:\:/_/gmx;
    my $time = time();
    $file_name = 'backup_' . $file_name . '_' . $time . '.yaml';

    my $save_file = file( $self->get_config_dir(), $file_name );

    if ( YAML::XS::DumpFile( $save_file, $return ) )
    {
        return
          $self->render(
                         json => {
                                   success   => $time,
                                   file_name => $save_file,
                         }
          );
    } else
    {
        $self->log(" YAML save error  $save_file: $!");
        return
          $self->render(
                         json => {
                                   success => 0,
                                   error   => "YAML save error  $save_file: $!",
                         }
          );
    }

}

sub show_documentation
{
    my $self = shift;
    my $module = $self->param('module') || 'Zoe';
    my $path =
      Pod::Simple::Search->new->find( $module, map { $_, "$_/pods" } @INC );
    return $self->redirect_to("https://metacpan.org/pod/$module")
      unless $path && -r $path;
    my $src = slurp $path;
    my $doc = $self->pod_to_html($src);
    return
      $self->render( text   => "<div id='perldoc'> $doc</div>",
                     layout => $layout );

}

sub delete
{
    my $self = shift;
    my %args = @_;
    my $type = my $__TYPE__ =
      $args{type} || $self->param('__TYPE__') || $self->stash('__TYPE__');
    eval "use $type";

    my $url = $args{url} || $self->stash('__URL__');
    my $message = $type . ' deleted';

    my $id     = $self->param('id');
    my $object = $type->find($id);

    $url = $self->_get_success($object) unless ($url);

    $object->delete();

    $self->flash( message => $message );

    return $self->render( json => { success => 1 } ) if $self->req->is_xhr;
    return $self->redirect_to($url);

}

sub _get_short_name
{
    my $self = shift;
    my $name = shift;
    $name =~ s/.*\:\:(\w+)$/$1/gmx;
    return $name;
}

sub log_not_authorized
{
    my $self = shift;

    #get client request info
    my $request_env = Dumper $self->req->env;
    my $log         = $self->get_logger('secure');
    my @params      = $self->param();
    my %param_values;

    foreach my $name (@params)
    {
        $param_values{$name} = $self->param($name);
    }
    $log->error(   __PACKAGE__
                 . " Client IP: "
                 . $self->tx->remote_address . "\nENV"
                 . $request_env
                 . "\nPARAMS:"
                 . Dumper %param_values );
    my $res = $self->tx->res;
    $res->code(401);
    $self->render( template => 'not_authorized', status => 402 );
}

sub auth_create
{
    my $self   = shift;
    my $object = shift;
    my $salt   = Data::GUID->new()->as_string;

    my $auth_config    = $self->get_auth_config();
    my $password_param = $auth_config->{login_password_param};
    my $password       = $self->param($password_param);
    my $password_hash  = sha1_hex( $salt . $password );

    my %auth_info = %{ $auth_config->{config}->{data_object} };

    my ( $salt_member, $password_member ) =
      ( $auth_info{salt_member}, $auth_info{password_member} );
    $object->{$password_member} = $password_hash;
    $object->{$salt_member}     = $salt;

    if ( $self->param('user_session_member') )
    {
        my $user_session_member = $self->param('user_session_member');

        $self->session(
             $auth_config->{user_session_key} => $object->{$user_session_member}
        );

    }
    return $object;

}

sub create
{
    my $self = shift;
    my %args = @_;
    my $type = my $__TYPE__ =
      $args{type} || $self->param('__TYPE__') || $self->stash('__TYPE__');
    eval "use $type";

    my $message = $args{message} || "$type created";
    my $object = $type->new();

    my $next_url_name =
      $self->stash('next_url_name') || $self->param('next_url_name') || 0;
    my $url;
    $url = $self->url_for($next_url_name) if ($next_url_name);
    $url = ( $args{url} || $self->_get_success($object) ) unless ($url);

    #set default values for object
    $object = $self->_get_values_from_description( $object, 'default_values' );

    $object = $self->_set_values_from_request_param($object);
    if ( $object->is_auth_object() )
    {
        $object = $self->auth_create($object);
    }

    #set mandatory values for object
    $object =
      $self->_get_values_from_description( $object, 'mandatory_values' );

    
    my $id = $object->save();

    $self->flash( message => $message );
    print Dumper $object;
    $self->_run_pre_render_handlers(object=>$object);

    return $self->render(
                         json => { success => $object->get_primary_key_value } )
      if $self->req->is_xhr;
    $self->redirect_to($url);

    return;
}

sub _get_values_from_description
{
    my $self   = shift;
    my $object = shift;
    my $key    = shift;

    my $page = $self->get_page();

    return $object unless ( $page->{$key} );

    foreach my $column_name ( $object->get_column_names() )
    {
        $object->{$column_name} = $page->{$key}->{$column_name}
          if ( $page->{$key}->{$column_name} );
    }

    return $object;
}

sub _check_is_admin_or_self
{
    my $self         = shift;
    my $object       = shift;
    my $auth_config  = $self->get_auth_config();
    my %auth_info    = %{ $auth_config->{config}->{data_object} };
    my $object_id    = $object->get_primary_key_value();
    my $current_role = $self->get_role_from_session() || {};
    my $current_user = $self->get_user_from_session()
      || {};
    my $admin_role = $auth_info{admin_role};

    return 1 if ( $admin_role eq '*' );

    return 1 if ( $admin_role eq $current_role->{TO_STRING} );

    return 1 if ( $object_id == $current_user->{PRIMARY_KEY_VALUE} );
    return 0;
}

sub auth_update
{
    my $self                  = shift;
    my $object                = shift;
    my $current_password_hash = shift;

    my $auth_config = $self->get_auth_config();
    my %auth_info   = %{ $auth_config->{config}->{data_object} };
    my ( $salt_member, $password_member ) =
      ( $auth_info{salt_member}, $auth_info{password_member} );

    #if password is not being updated just return
    my $new_password = $self->param('password_hash');

    return $object unless (length ($new_password) );
    print "NEW PASSWORD $new_password\n\n";
    my $old_password = $self->param('old_password');

    unless ($old_password)
    {
        $self->stash( 'message' => 'bad previous password' );
        
        throw Mojo::Exception->throw('__BAD_CURRENT_PASSWORD__');
    }

   #make sure current user has rights to edit user or redirect_to not authorized

    #get current user

    my $current_salt = $object->{$salt_member} || '';

    my $old_password_hash = sha1_hex( $current_salt . $old_password );

#get the current role
 
    # if new and old password match
    my $admin_role = $auth_info{admin_role};
    if ( $current_password_hash eq $old_password_hash )
    {
        my $salt          = Data::GUID->new()->as_string;
        my $password_hash = sha1_hex( $salt . $new_password );

        $object->{$password_member} = $password_hash;
        $object->{$salt_member}     = $salt;
        return $object;
    } else
    {
        $self->flash( 'message', => 'Bad current password' );
        
        throw Mojo::Exception->throw('__BAD_CURRENT_PASSWORD__');

    }

}

sub update
{
    my $self = shift;
    my %args = @_;
    my $type = my $__TYPE__ =
      $args{type} || $self->param('__TYPE__') || $self->stash('__TYPE__');
    eval "use $type";
    my $message     = $args{message} || "$type updated";
    my $id          = $self->param('id');
    my $object      = $type->find($id);
    my $auth_config = $self->get_auth_config();
    my %auth_info   = %{ $auth_config->{config}->{data_object} };
    my ( $salt_member, $password_member ) =
      ( $auth_info{salt_member}, $auth_info{password_member} );

    my $current_password = $object->{$password_member};

    my $next_url_name =
      $self->stash('next_url_name') || $self->param('next_url_name') || 0;
    my $url;
    $url =
      $self->url_for($next_url_name)
      ->query( [ id => $id, message => $message ] )
      if ($next_url_name);
    $url = ( $args{url} || $self->_get_success($object) ) unless ($url);
    $self->flash( 'message', $message );

    my $update_object;

    #set default values for object
    $object = $self->_get_values_from_description( $object, 'default_values' );

    $object = $self->_set_values_from_request_param($object);

    if ( $object->is_auth_object() )
    {

        #check if user is authorized to update
        my $authorized = $self->_check_is_admin_or_self($object);
        unless ($authorized)
        {
            return $self->log_not_authorized(
                              
                                 object_id => $object->get_primary_key_value(),
                                 path      => $self->url_for()
                               
            );

            
        }
        try
        {

            $update_object = $self->auth_update( $object, $current_password );
            $object = $update_object;

            #set mandatory values for object
            $object = $self->_get_values_from_description( $object,
                                                           'mandatory_values' );
            
            
            $object->save;
            

        }
        catch
        {

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
            return $self->render(
                   json => { success => 0, message => 'Bad current password' } )
              if $self->req->is_xhr;
            $self->redirect_to($url);
        };

    } else
    {
        
        $object->save;

    }
    use Data::Dumper;
    #print Dumper $object->load($object->get_primary_key_value())->get_Artifacts();
    $self->_run_pre_render_handlers(object=>$object);

#return $self->render(json=>{success => ($object->get_primary_key_value )}) if $self->req->is_xhr;
    return $self->redirect_to($url);
}

sub _eval_where
{
    my $self = shift;

    my $where = shift || {};

    my $new_where = {};
    my $__USER__  = $self->get_user_from_session();
    foreach my $key ( keys( %{$where} ) )
    {
        my $value = $where->{$key};

        #$key = eval($key) || $key;
        $new_where->{$key} = $value;
        $new_where->{$key} = eval($value) unless ( ref($value) );

        #$new_where->{ $key } = eval($value) ;
        # $new_where->{ $key } = 1;

    }

    return $new_where;
}

sub show_all
{
    my $self        = shift;
    my %args        = @_;
    my $render_json = $args{render_json};

    my $type = my $__TYPE__ =
      $args{type} || $self->param('__TYPE__') || $self->stash('__TYPE__');
    eval "use $type";

    my $template =
      $self->stash('template') || $args{template} || 'zoe/show_all';

    my $limit =
      $args{limit} || $self->param('limit') || $self->stash('limit') || 10;

    my $where = $args{where} || $self->stash('where') || {};

    $where = $self->_eval_where($where);

    my $object = $type->new;
    my $helper_opts = $args{helper_opts} || $self->stash('helper_opts') || {};

    my $order = $self->param('order_by') || $self->stash('order_by');
    my $offset = $self->param('offset') || $self->stash('offset') || 0;
    $layout = $args{layout} || $self->stash('layout') || $layout;

    my $order_by = [];
    if ($order)
    {
        $order_by = [$order];
    }
    my $count = scalar( $type->find_all( where => $where ) );
    my @all = $type->find_all(
                               order  => $order_by,
                               limit  => $limit,
                               offset => $offset,
                               where  => $where
    );

    my $search;

    my %return = (
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
                   type        => $type,
    );

    $self->_run_pre_render_handlers(%return);
    #unbless objects -> turn into hash
    my @all_json = @all;
    foreach my $obj (@all_json)
    {
        my %tmp_hash = %{$obj};
        $obj = \%tmp_hash;

    }

    if ( $self->req->is_xhr )
    {
        my $page = $self->render_to_string(
            search      => $search,
            object      => $object,
            limit       => $limit,
            count       => $count,
            offset      => $offset,
            order_by    => $order,
            all         => \@all,
            template    => $template,
            helper_opts => $helper_opts,
            layout      => '',
            type        => $type,

        );
        return
          $self->render(
                         json => {
                                   success => 1,
                                   object  => \@all_json,
                                   page    => $page,
                         }
          );
    }
    return
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
                     type        => $type,
      ) or die "$!";
}

sub show
{
    my $self = shift;
    my %args = @_;
    my $type = 
      $args{type} || $self->param('__TYPE__') || $self->stash('__TYPE__');
    my $__TYPE__= $type;  
    eval "use $type";

    my $template = $args{template} || $self->stash('template') || 'zoe/show';
    my $helper_opts = $args{helper_opts} || $self->stash('helper_opts') || {};
    $layout = $args{layout} || $self->stash('layout') || $layout;
    my $id = $self->param('id');

    my $object = $type->find($id);

    $self->_run_pre_render_handlers(object=>$object);
    
    my %obj_hash = %{$object};

    if ( $self->req->is_xhr )
    {
        my $page =
          $self->render_to_string(
                                   object      => $object,
                                   template    => $template,
                                   helper_opts => $helper_opts,
                                   layout      => '',
                                   type        => $type,
          );

        #   if ajax
        return
          $self->render(
                         json => {
                                   success => 1,
                                   object  => \%obj_hash,
                                   page    => $page,
                         }
          );
    }

    # else
    return
      $self->render(
                     object      => $object,
                     template    => $template,
                     helper_opts => $helper_opts,
                     layout      => $layout,
                     type        => $type,
      );
}

sub show_create
{
    my $self = shift;
    my %args = @_;
    $args{object_action} = '_create';

    return $self->show_create_edit(%args);
}

sub show_edit
{
    my $self = shift;
    my %args = @_;
    $args{object_action} = '_update';

    return $self->show_create_edit(%args);
}

sub show_create_edit
{
    my $self = shift;

    my %args = @_;
    my $type = my $__TYPE__ =
      $args{type} || $self->param('__TYPE__') || $self->stash('__TYPE__');
    eval "use $type";

    my $template =
      $args{template} || $self->stash('template') || 'zoe/create_edit';
    my $object_action =
         $args{object_action}
      || $self->param('__OBJECTACTION__')
      || $self->stash('__OBJECTACTION__');

    my $id        = $self->param('id');
    my $message   = $self->param('message') || '';
    my $error_msg = $self->param('error_msg') || '';
    my $object    = $type->find($id) || $type->new;

    #set default values for object
    $object = $self->_get_values_from_description( $object, 'default_values' );

    #set mandatory values for object
    $object =
      $self->_get_values_from_description( $object, 'mandatory_values' );
      
   
   
    $self->_run_pre_render_handlers(object=>$object);   

    my $helper_opts = $args{helper_opts} || $self->stash('helper_opts') || {};

    $layout = $args{layout} || $self->stash('layout') || $layout;

    if ( $self->req->is_xhr )
    {
        my $page =
          $self->render_to_string(
                                   object        => $object,
                                   template      => $template,
                                   helper_opts   => $helper_opts,
                                   layout        => '',
                                   message       => $message,
                                   error_msg     => $error_msg,
                                   type          => $type,
                                   object_action => $object_action,
          );

        return
          $self->rend(
                       json => {
                                 page => $page,
                       }
          );
    }

    return
      $self->render(
                     object        => $object,
                     template      => $template,
                     helper_opts   => $helper_opts,
                     layout        => $layout,
                     message       => $message,
                     error_msg     => $error_msg,
                     type          => $type,
                     object_action => $object_action,
      );

}

sub portal_search
{
    my $self = shift;
    my $type = $self->param('__TYPE__');

    return $self->search(@_) if ($type);

    my %args = @_;

    my $portal = $self->get_portal();

    my %models         = %{ $portal->{models} };
    my $limit          = $portal->{search}->{limit};
    my $search_results = {};
    foreach my $model ( keys(%models) )
    {
        my $link_to = $models{$model};
        $search_results->{$model}->{$link_to} =
          $self->search( __TYPE__ => $model,
                         limit    => $limit, );
    }

}

sub search
{
    my $self = shift;
    my %args = @_;
    my $type =
      $args{type} || $self->param('__TYPE__') || $self->stash('__TYPE__');
    eval "use $type";

    my $template =
      $args{template} || $self->stash('template') || 'zoe/show_all';
    my $limit = $args{limit} || $self->stash('limit') || 10;
    my $where = $args{where} || $self->stash('where') || {};
    my $object = $type->new;
    my $helper_opts =
         $args{helper_opts}
      || $self->stash('helper_opts')
      || {};    #options to the helper
    my @args = ();

    if ( $args{args} )
    {
        @args = @{ $args{args} };

    }

    my @columns = $type->get_searchable_columns();
    my $search  = $self->param('search');
    my $order   = $self->param('order_by') || $self->stash('order_by');

    my $offset = $self->param('offset') || $self->stash('offset') || 0;
    my $order_by = [];
    if ($order)
    {
        $order_by = [$order];
    }

    my $count = scalar(
                        $object->search(
                                         columns => \@columns,
                                         search  => $search,
                                         where   => $where
                        )
    );
    my @all = $object->search(
                               columns => \@columns,
                               search  => $search,
                               order   => $order_by,
                               limit   => $limit,
                               offset  => $offset,
                               where   => $where
    );
    
    $self->_run_pre_render_handlers(allt=>@all);

    return @all if ( $args{return_all} );

    if ( $self->req->is_xhr() )
    {

        #unbless objects -> turn into hash
        foreach my $obj (@all)
        {
            my %tmp_hash = %{$obj};
            $obj = \%tmp_hash;

        }

        my $page = $self->render_string(
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
                                         layout      => '',
                                         type        => $type,
                                         @args
        );
        return
          $self->render(
                         json => {
                                   object  => \@all,
                                   success => 1,
                                   page    => $page
                         },
                         ,
          );
    }

    $layout = $args{layout} || $self->stash('layout') || $layout;
    if (@args)
    {
        return
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
                         type        => $type,
                         @args
          );
    } else
    {
        return $self->render(
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
            type        => $type,

        );

    }

}

sub _get_success
{
    my $self   = shift;
    my $object = shift;
    my %args   = @_;
    my $type   = my $__TYPE__ =
      $args{type} || $self->param('__TYPE__') || $self->stash('__TYPE__');

    if ( !$object || $type )
    {
        eval "use $type";
        $object = $type->new();

    }
    my $success_path = lc( $object->get_object_type );
    $success_path =~ s/\:\:/_/gmx;
    $success_path .= '_show_all';

    my $url = $self->url_for($success_path);
    return $url;
}

sub _get_upload
{
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

sub _set_values_from_request_param
{

    my ( $self, $object ) = @_;
    my $pkey_name     = $object->get_primary_key_name();
    my @columns       = $object->get_column_names();
    my %column_info   = $object->get_column_info();
    my $log           = $self->get_logger('debug');
    my %linked_create = %{ $object->get_linked_create() };

    foreach my $column (@columns)
    {
        my $member_name = $object->get_member_for_column($column) || 0;
        my $input_type  = $column_info{$column};
        my $method      = "set_$column";
        my $get_method  = "get_$column";
        next if ( $column eq $pkey_name );

        if ( $input_type eq 'file' )
        {

            #my $uploaded_file   = $self->param($column);
            #see if file to be uploaded is specified
            my $public_path = $self->_get_upload( $object, $column );
            if ($public_path)
            {

                $object->$method($public_path);

            }

        } elsif (    ( defined($column) )
                  && ( defined( $linked_create{$member_name} ) )
                  && $self->param($column) )
        {
            if ( $self->param($column) =~ /^\d+$/ )
            {    #object was selected from drop dwon
                $object->{$column} = $self->param($column);
            } else
            {

                my $type = $linked_create{$member_name};
                eval "use $type";

                my $belongs_to_ob =
                  $type->new( %{ json_to_perl( $self->param($column) ) } );
                $belongs_to_ob->save();
                $object->{$column} = $belongs_to_ob->get_primary_key_value();

            }

        } else
        {

            my $value = $self->param($column);
            $object->$method($value) if ($value);
        }
    }

    my @many_to_many_members = $object->get_many_to_many_member_names();
    my @has_many_members     = $object->get_has_many_member_names();
    my @members              = ( @has_many_members, @many_to_many_members );

    foreach my $member_name (@members)
    {

        my $method = 'set_' . $member_name;
        my $type   = $object->get_type_for_many_member($member_name);
        eval "use $type";

        my @id_list = @{$self->every_param($member_name)};
        @id_list = $self->param($member_name .'[]') unless (@id_list);
        print Dumper @id_list;
       
       
       
        $log->debug( "member_name $member_name" . Dumper @id_list );
        my @object_list;

        foreach my $id (@id_list)
        {

            #undef value was being added to @id_list; weird;
            next unless $id;

            if ( $id =~ /^\d+$/ )
            {    #object was selected from drop dwon
                my $many_object = $type->find($id);

                push( @object_list, $many_object );
            } else
            {    #new object
                my $type = $object->get_type_for_many_member($member_name);
                eval "use $type";
                my %rel_column_info = $type->new()->get_column_info();

                #id is a json string containing object values
                my $values = json_to_perl($id);
                foreach my $rel_column ( keys %{$values} )
                {
                    my $rel_input_type = $rel_column_info{$rel_column};
                    next unless $rel_input_type;    # ignore empty entry json

                    if ( $rel_input_type eq 'file' )
                    {
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

sub handle_portal_request
{
    my $self      = shift;
    my $site      = $self->param('__PORTAL__');
    my $page_name = $self->param('__PAGE__');
    my $runtime   = $self->get_runtime();
    my $page      = $runtime->{sites}->{$site}->{$page_name};
    my $action    = $page->{action};
    my $template  = ( $page->{template} || 0 );
    my $layout    = ( $page->{layout} || 0 );
    my $where     = ( $page->{where} || 0 );
    my $handler   = ( $page->{handler} || 0 );
    my $type      = ( $page->{type} || 0 );

    if ($handler)
    {
        eval "use $handler";
        return $handler->new()->$action( controller => $self, page => $page );
    } else
    {
        return
          $self->$action(
                          template => $template,
                          layout   => $layout,
                          type     => $type
          );
    }
}
    
sub _run_pre_render_handlers {
    my $self = shift;
    my @pre_render_handlers = ();
    @pre_render_handlers = @{ $self->stash('pre_render_handlers') } 
        if ($self->stash('pre_render_handlers'));
    foreach my $handler (@pre_render_handlers) {
        foreach my $class (keys( %{ $handler})){
            my $method = $handler->{$class};
            
            eval "use $class";
            $class->new($self)->$method(@_);
        }
    }
}
1;
