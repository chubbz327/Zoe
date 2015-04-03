package Zoe::RuntimeController;
use Mojo::Base 'Mojolicious::Controller';
use YAML::XS;
use Path::Class;
BEGIN { unshift @INC, "$FindBin::Bin/../" }

sub show_manage {
    
    my $self =shift;
    my %args    = @_;
    my $message = $self->param('message') || $args{message} || $self->stash('message') || '';
    
    my $cmd = "ls " . $self->get_import_backup_dir();
    my @import_files = split(/\n/, `$cmd` );
    
    $cmd = "ls " . $self->get_runtime_backup_dir();
    my @runtime_files = split(/\n/, `$cmd` );
    
    $self->render(      
        template => "zoe/manage",   
        message => $message,
        runtime_files => \@runtime_files,
        import_files => \@import_files,
            
    );
}

sub show_runtime {
    my $self =shift;
    my %args    = @_;
    my $runtime = $self->get_runtime();
    my $key = $self->param('key') || 0;
    my $selected_ref = $runtime;
    $selected_ref = $runtime->{$key} if ( ($key) && defined($runtime->{$key}));
    my $message = $self->param('message') || $args{message} || $self->stash('message') || '';
     $self->render(     
        runtime => $runtime,
        template => "zoe/runtime",   
        selected_ref => $selected_ref,
        key => $key,
        message => $message,
            
    );
    
    
}

sub save_runtime {
    my $self = shift;
    my $key = $self->param('key') || 0;
    my $name = $self->param('name') || return $self->show_runtime(message => "name field is mandatory");
    my $runtime = $self->get_runtime();
    my $error; 
    my $runtime_string = $self->param('runtime');
    
    $runtime_string =~ s/\t//g; #remove tab added by textarea
    my $value_ref = YAML::XS::Load( $runtime_string ) or $error = "Could not update runtime: parse error $!";
    $self->log($error || '');
    return $self->show_runtime(message => $error) if $error;
    
    if ($key) {
        $runtime->{$key} = $value_ref;
    }else {
        $runtime = $value_ref;
    }
    $runtime->{$name} = $name; 
    
    my $file_name = 'modified_' . 'runtime_' . $name. '.yaml';
    my $save_file = file( $self->get_runtime_backup_dir(), $file_name );
     YAML::XS::DumpFile( $save_file, $runtime ) or $error = "Could not write modified runtime $file_name  $!";
     return $self->log($error) if $error;
     $self->flash(message=> "$file_name created");
     $self->redirect_to($self->url_for('__SHOW_RUNTIME__', message=>"$file_name created"));
}

sub restart_app {
    my $self = shift;
    my $lib_dir = $self->get_lib_dir();
    my $startup_script = $self->get_startup_script();
    
    my $pid = $$;
    my $command = "kill -9 $pid && env nohup perl -I $lib_dir $startup_script daemon & ";
    print $command ."\n\n\n";
    my $output = ` $command`;
    $output .= "\n$!";
    my $is_error = $?;
    $self->render( json=>{
        success=>1,
        output => $output
    })
    
    
}

sub generate {
    my $self = shift;
    my $import_stmt ='';
    
    my $app_file = file ($self->get_runtime_backup_dir() , $self->param('runtime_file') );
    my $import_file = $self->param('import_file') || 0;
    
    
    if ($import_file){
        $import_file = file ($self->get_import_backup_dir(), $import_file );
        $import_stmt = "--import=$import_file";   
    }
    
    
    
    my $lib_dir = $self->get_lib_dir();
    my $startup_script = $self->get_startup_script();
    my $pid = $$;
    my $command = "zoe-generator --app_file=$app_file  $import_stmt ";
      # my $command = "kill -9 $pid && env perl zoe-generate --app_file = $app_file  $import_stmt && env perl -I $lib_dir $startup_script  daemon";
    
    my $output = `$command`;
    $output .= "\n$!";
    print $command . "\n\n\n";
    my $is_error = $?;
    $self->render( json=>{
        success=>1,
        output => $output
    })
    

}


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
    my $save_file = file( $self->get_import_backup_dir(), $file_name );
    if ( YAML::XS::DumpFile( $save_file, $return ) )
    {
        return
          $self->render(
                         json => {
                                   success   => $time,
                                   file_name => $save_file,
                                   msg      => "$save_file saved",
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
1;
