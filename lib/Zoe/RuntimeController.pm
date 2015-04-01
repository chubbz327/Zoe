package Zoe::RuntimeController;
use Mojo::Base 'Mojolicious::Controller';
use YAML::XS;
use Path::Class;
BEGIN { unshift @INC, "$FindBin::Bin/../" }


sub show {
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

sub save {
    my $self = shift;
    my $key = $self->param('key') || 0;
    my $runtime = $self->get_runtime();
    my $error; 
    my $runtime_string = $self->param('runtime');
    
    $runtime_string =~ s/\t//g; #remove tab added by textarea
    my $value_ref = YAML::XS::Load( $runtime_string ) or $error = "Could not update runtime: parse error $!";
    $self->log($error || '');
    return $self->show(message => $error) if $error;
    
    if ($key) {
        $runtime->{$key} = $value_ref;
    }else {
        $runtime = $value_ref;
    }
    
    my $time      = time();
    my $file_name = 'modified_' . 'runtime_' . $time . '.yaml';
    my $save_file = file( $self->get_config_dir(), $file_name );
     YAML::XS::DumpFile( $save_file, $runtime ) or $error = "Could not write modified runtime $file_name  $!";
     return $self->log($error) if $error;
     $self->flash(message=> "$file_name created");
     $self->redirect_to($self->url_for('__SHOW_RUNTIME__', message=>"$file_name created"));
}
1;
