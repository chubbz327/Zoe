package Zoe::DO::CartItem;
use Data::Serializer;

use Mojo::Base -base;

has 'index';
has 'item_type';
has 'item_id';
has 'price';
has 'quantity';
has 'title';

sub line_total {
    my $self = shift;
     return ($self->price * $self->quantity);
}
sub to_string {
    my $self = shift;
    return Data::Serializer->new()->serialize($self);
}


1;