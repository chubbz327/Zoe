package Zoe::ObjectToHtml;

use Mojo::Base -strict;

sub new {
    my $class = shift; 
      my %arg  = @_;
    my $self = {
     
        %arg
    };

    return bless $self, $class;    
}



sub to_form_fragment {
    my $self    = shift;
    my %args    = @_;
    
    my $object = $args{object};
    my @ignore  = ();
    if (defined($args{ignore})) {
        @ignore = @{ $args{ignore} };
    }
    #determine type of top level object
    my $type =  ref ($object);
    
    
}

package main; 
use Zoe::ObjectMeta;

my $a = {};
my $b = [];
my $c = Zoe::ObjectMeta->new();

my $o2html = Zoe::ObjectToHtml->new();
say $o2html->to_form_fragment( object => $a);
say $o2html->to_form_fragment( object => $b);
say $o2html->to_form_fragment( object => $c);

print "hello";

