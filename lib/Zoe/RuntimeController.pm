package Zoe::RuntimeController;
use Mojo::Base 'Mojolicious::Controller';

BEGIN { unshift @INC, "$FindBin::Bin/../" }


sub show {
    my $self =shift;
    my $runtime = $self->get_runtime();
    my $runtime_keys    = $runtime->get_keys();
    $self->render(     
        runtime => $runtime,
        template => "runtime",   
        runtime_keys => $runtime_keys,     
    );
    
    
}

sub save {
    my $self = shift;
    
}
1;
