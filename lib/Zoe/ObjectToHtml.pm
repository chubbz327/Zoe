package ObjectToHtml;

use Mojo::Base -strict;

sub new {
    
}



sub to_form_fragment {
    my $self    = shift;
    my %args    = @_;
    
    my $object = $args{object};
    my @ignore  = ();
    if (defined($args{ignore})) {
        @ignore = @{ $args{ignore} };
    }
    
    
    
}