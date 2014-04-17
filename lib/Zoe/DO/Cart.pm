package Zoe::DO::Cart;
use Data::Serializer;
use Zoe::DO::CartItem;

use Mojo::Base -base;

has 'CartItems' => ();
has 'total';



sub add_to_cart {
    my $self = shift;
    my %args = @_;
    
    my %cart_items = ();   
    %cart_items = %{ $self->CartItems } if ($self->CartItems);
    my $index = (keys ( %cart_items) + 1 ) || 1;
    
    $args{index} = $index;
    my $item = Zoe::DO::CartItem->new( %args);
    
    $cart_items{$index} = $item;
    $self->CartItems(\%cart_items);
    $self->update_total();
    return;         
}
sub remove_from_cart {
    my $self = shift;
    my $index = shift;
    my %cart_items = ();   
    %cart_items = %{ $self->CartItems } if ($self->CartItems);
    
    return unless ( keys (%cart_items) );
    
    #remove item from list via index
    delete $cart_items{$index};
    
    #rebuild indexe
    my %new_items;
    my $new_index =1;
    foreach  my $old_index (sort (keys ( %cart_items ))) {
        my $cart_item = $cart_items{$old_index};
        $cart_item->index($new_index);
        $new_items{$new_index} = $cart_item;
        $new_index++;
    }    
    %cart_items = %new_items;
        $self->CartItems(\%cart_items);
    $self->update_total();
    return;   
}

sub update_total {
    my $self = shift;
    my $total = 0;
    my %cart_items = ();   
    %cart_items = %{ $self->CartItems } if ($self->CartItems);
     
    foreach my $index ( keys ( %cart_items )) {
        my $item = $cart_items{$index};
        $total += $item->line_total();
    
    }
    $self->total($total);
    return $total;
}





1;