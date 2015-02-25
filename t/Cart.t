use Mojo::Base -strict;

#use Test::More tests => 'no_plan';
use Test::More 'no_plan';
use Data::Serializer;
my $cwd; #current working directory

BEGIN {
    use_ok("File::Basename");
    use_ok("File::Spec::Functions");
    use_ok("Path::Class");
   
    $cwd = File::Spec->rel2abs( catdir( dirname(__FILE__) ) );
    use File::Basename 'dirname';
    use File::Spec::Functions 'catdir';
    use File::Path qw(make_path remove_tree);

    unshift @INC, "" . dir( $cwd, '..', 'lib' );
 
    use_ok("Zoe::DO::CartItem");
    use_ok("Zoe::DO::Cart");
    
}

#confirm cart creation, adding CartItemItems and de/serialize
my $cart = Zoe::DO::Cart->new();
$cart->add_to_cart ( item_type => 'Product',
                     item_id => 1,
                     price => 10,
                     quantity =>  '3',
                     title => 'testing cart');
                     
$cart->add_to_cart ( item_type => 'Product',
                     item_id => 3,
                     price => 5,
                     quantity =>  '3',
                     title => 'testing cart');                     
                     
my $serialized_cart = Data::Serializer->new()->serialize($cart);
my $cart2 = Data::Serializer->new()->deserialize($serialized_cart);

is($cart2->update_total, $cart->update_total, 'Serialization/Deserialization');

    
#remove from cart works
$cart2->remove_from_cart(1);           

is($cart2->update_total, 15, 'Serialization/Deserialization'); 
1;
