package Zoe::PayPayTransactionController;

use Business::PayPal::NVP;

use Data::Serializer;
use Mojo::Base 'Mojolicious::Controller';
use FindBin;
use Data::Dumper;
use Mojo::Log;

BEGIN { unshift @INC, "$FindBin::Bin/../"; }
use Zoe::DO::Cart;
use Zoe::DO::CartItem;

sub _get_cart {
    my $self   = shift;
    my $logger = $self->get_logger('paypal');

    #get cart from session
    my $paypal_config    = $self->get_paypal_config;
    my $cart_session_key = $paypal_config->{cart_session_key} || '__CART__';
    my $serialized_cart  = $self->session($cart_session_key);

    unless ($serialized_cart) {
        return Zoe::DO::Cart->new;
        $self->_log( ': New Cart created' );
    }
    $self->_log( 
           ': Cart returned from session variable '
          . $cart_session_key );
    return Data::Serializer->new()->deserialize($serialized_cart);

}

sub paypal_transaction {
    my $self                    = shift;
    
    #get paypal configuration
    my $paypal_config           = $self->get_paypal_config();
    #set url do_express_checkout will redirect to if completed succcessfuly
    my $post_paypal_redirect_to = '__PAYPALTRANSACTION__';
    #used to pass to paypal iframe to redirect parent
    my $reload_parent           = $self->url_for($post_paypal_redirect_to);
    
    #sellable object
    my $sellable_object         = $paypal_config->{sellable_object};
    
    #object that saves record of sale
    my $payment_record_object   = $paypal_config->{payment_record_object};
    my $message = $self->param('message') || 0;
    
    #load
    require $sellable_object . ".pm";
    require $payment_record_object . ".pm";
    
    #get list for slects
    my @all    = $sellable_object->find_all();
    my @all_records   = $payment_record_object->find_all();
    
    # get the primary key name of the payment record object to be used as a request parameter
    my $payment_record_object_pkey_name = $payment_record_object->new()->get_primary_key_name();
       
    my $cart   = $self->_get_cart();
    my $layout = 'zoe';
    $self->render(
        template                => 'paypal_transaction',
        all_records             => \@all_records,
        all                     => \@all,
        cart                    => $cart,
        layout                  => $layout,
        post_paypal_redirect_to => $post_paypal_redirect_to,
        reload_parent           => $reload_parent,
        payment_record_object_pkey_name => $payment_record_object_pkey_name,
        message                 => $message,
    );

}

sub _set_cart {
    my $self = shift;
    my $cart = shift;

    #get cart from session
    my $paypal_config    = $self->get_paypal_config;
    my $cart_session_key = $paypal_config->{cart_session_key} || '__CART__';
    my $serialized_cart  = Data::Serializer->new()->serialize($cart);
    $self->session( $cart_session_key => $serialized_cart );
    return 1;
}

sub paypal_cancel {
    my $self = shift;

}

sub view_cart {
    my $self = shift;
    #get cart
    my $cart = $self->_get_cart();
    my $template = $self->param('template') || 'cart';
    #pass to layout
    my $layout = $self->param('layout') || 0;
    my $cart_html = $self->render(
        'template' => $template,
        partial    => 1,
        cart       => $cart,
        layout     => $layout, 
    );

    #if ajax return cart partial template
    if ( $self->req->is_xhr ) {
        print $cart_html;
        $self->render( text => $cart_html );
    }
    else {
        $self->render(
            template => 'cart',
            cart     => $cart,
            layout   => $layout,
        );
    }
}

sub add_to_cart {
    my $self = shift;
    my %args = ();
    
    #get sellable_object
    my $paypal_config = $self->get_paypal_config;
    my $sellable_object = $paypal_config->{sellable_object};
    require $sellable_object . ".pm";
    my $object = $sellable_object->find( $self->param('item_id') );

    #add cart item details
    $args{quantity}  = $self->param('quantity');
    $args{item_type} = $sellable_object;
    $args{item_id}   = $self->param('item_id');
    $args{price}     = $object->get_price();
    $args{title}     = $object->get_title;
    my $digital_item = $self->param('digital_item') || 0;

    my $cart = $self->_get_cart();
    
    my %cart_items = (); 
    
    #add cart item
    if ( $cart->CartItems() ){
        %cart_items = %{$cart->CartItems()};
    }
    my $match = 0;
    
    foreach my $index ( keys (%cart_items) ) {
        #get reference to cart item
        my $cart_item = $cart_items{$index};
        if ($cart_item->item_id == $args{item_id}) {
            $match = 1; 
            my $quantity =  $cart_item->quantity + $args{quantity};
            $cart_item->quantity( $quantity);
            $cart->remove_from_cart($index);
            $cart->add_to_cart($cart_item) unless ($digital_item);
            
        }
    }
    unless ($match ) {
        $cart->add_to_cart(%args);
        $self->_set_cart($cart);
    }
    $self->_log('Cart updated ' . Dumper $cart );

    return $self->_do_redirect_or_render();
}

sub update_cart_item_quantity {
    my $self = shift;
    
    #get item details from request params
    my $quantity = $self->param('cart_item_quantity');
    my $index    = $self->param('cart_item_index');
    my $cart     = $self->_get_cart();

    #if quantity is 0 remove from the cart
    if ( !$quantity ) {
        #remove item from cart
        $cart->remove_from_cart($index);
        $self->_set_cart($cart);
    }
    else {
        my %cartItems = %{ $cart->CartItems() };
        my $cart_item = $cartItems{$index};

        $cart_item->quantity($quantity);
        $cartItems{$index} = $cart_item;
        $cart->CartItems( \%cartItems );
        $self->_set_cart($cart);
    }
    $self->_log('Cart updated ' . Dumper $cart);
    return $self->_do_redirect_or_render();

}

sub remove_from_cart {
    my $self  = shift;
    #get index of item to be removed
    my $index = $self->param('cart_item_index');
    my $cart  = $self->_get_cart();
    #remove
    $cart->remove_from_cart($index);
    $self->_set_cart($cart);

    $self->_log('Cart updated ' . Dumper $cart);
    return $self->_do_redirect_or_render();

}

#if redirect_to specifed, redirects; otherwise calls view_cart
sub _do_redirect_or_render {
    my $self = shift;
    my $redirect_to = $self->param('redirect_to') || 0;

    if ($redirect_to) {
        $self->_log("Redirecting to $redirect_to");

        return $self->redirect_to( $self->url_with($redirect_to) );
    }
    else {
        return $self->view_cart();
    }
}

sub _get_paypal {
    my $self = shift;

    #get config
    my $paypal_config = $self->get_paypal_config;

    #determine the branch live vs test
    my $branch = $paypal_config->{credentials}->{branch};

    #get auth info for branch
    my $auth_info = $paypal_config->{credentials}->{$branch};

    my $paypal = new Business::PayPal::NVP(
        $branch => $auth_info,
        branch  => $branch,
    );

    return $paypal;
}

sub _transaction_failed {
    my $self          = shift;
    my $message       = shift;
    my $step          = ( caller(1) )[3];
    my $paypal_config = $self->get_paypal_config();
    my $logger        = $self->get_logger('paypal');
    $self->_log( ": Paypal transaction failed at step $step " . $message );

    #redirect to transaction_failed_url_name:
    if ( $paypal_config->{transaction_failed_url_name} ) {
        $self->_log( 
               ": Redirecting to "
              . $paypal_config->{transaction_failed_url_name} );
        return $self->redirect_to(
            $self->url_for( $paypal_config->{transaction_failed_url_name} ) );
    }

    #remove session variables
    $self->_remove_cart_from_session();

    #render the template
    my $reload_parent = $self->url_for();
    my $layout = 'zoe';
    return $self->render(   template => 'paypal_transaction_failed', 
                            layout => $layout, 
                            reload_parent => $reload_parent  
                        );
}

#parses paypal config and assigns the values for the cart to paypal request params
sub _get_paypal_request_options {
    my $self                  = shift;
    my $paypal_config         = $self->get_paypal_config;
    my $total                 = shift;
    my %paypal_request_params = ();

    #add item specific request options - map to cartItemvalues
    my %paypal_request_map = %{ $paypal_config->{paypal_request_map} };
    my %paypal_request_cart_item_params =
      %{ $paypal_config->{paypal_request_cart_item_params} };

    my $cart      = $self->_get_cart;
    my %cartItems = %{ $cart->CartItems };
    my $inc       = 0;

    #paypalrequest item increment
    foreach my $index ( keys(%cartItems) ) {
        my $inc_val  = '_' . $inc . '_';
        my $cartItem = $cartItems{$index};
        foreach my $key ( keys(%paypal_request_map) ) {

            my $method = $paypal_request_map{$key};

            #$key =~ s/_0_/$inc_val/g;
            $key .= $inc;
            $paypal_request_params{$key} = $cartItem->$method;

            #print "\n\nKEY$key\n\n";
        }

        foreach my $key ( keys(%paypal_request_cart_item_params) ) {
            my $value = $paypal_request_cart_item_params{$key};
            $key .= $inc;    #increment key for paypal request param
            $paypal_request_params{$key} = $value;
        }
        $inc++;
    }
    return %paypal_request_params;
}

sub set_express_checkout {
    my $self   = shift;
    my $paypal = $self->_get_paypal();
    my $logger = $self->get_logger('paypal');

    #paypal config
    my $paypal_config = $self->get_paypal_config;

    #get cart from session
    my $cart            = $self->_get_cart();
    my $serialized_cart = Data::Serializer->new()->serialize($cart);

    #build paypal request
    my $return_url = $self->url_for('__DOEXPRESSCHECKOUT__')->to_abs->to_string;
    my $cancel_url = $self->url_for('__PAYPALCANCEL__')->to_abs->to_string;

    #convert int to float
    my $total = sprintf( "%.2f", $cart->update_total )
      if ( int( $cart->update_total() ) );

    #paypal api work around
    delete $ENV{$_} for grep { /^(HTTPS|SSL)/ } keys %ENV;
    local $IO::Socket::SSL::VERSION = undef;

    #set the options used by the express checkout

    my %paypal_request_params = (
        METHOD                         => 'SetExpressCheckout',
        RETURNURL                      => $return_url,
        CANCELURL                      => $cancel_url,
        PAYMENTREQUEST_0_AMT           => $total,
        PAYMENTREQUEST_0_ITEMAMT       => $total,
        PAYMENTREQUEST_0_PAYMENTACTION => 'Sale',
    );

    #add the request options from conf file
    %paypal_request_params =
      ( %paypal_request_params, %{ $paypal_config->{paypal_request_params} } );

    return 0 unless $cart->CartItems;
    %paypal_request_params =
      ( %paypal_request_params, $self->_get_paypal_request_options($total) );

    $self->_log('Request parameters sent ' . Dumper %paypal_request_params);

    #set express checkout
    my %paypal_response = $paypal->send(%paypal_request_params) or do {
        $self->_log( join( "\n", $paypal->errors ) );
    };
     $self->_log('Paypal response ' . Dumper %paypal_response);
    unless ( $paypal_response{ACK} =~ /Success/i ) {
        return $self->_transaction_failed(' SetExpressCheckout failed');
    }
    $self->_log(
          ": Paypal SetExpressCheckout success for token "
          . $paypal_response{TOKEN} );

    my $token = $paypal_response{TOKEN};

    #add paypal payment details to the session
    $self->session( 'Token' => $token );
    $self->session( $token
          . "__POSTPAYPALREDIRECT__" => $self->param('__POSTPAYPALREDIRECT__')
    );
    
    $self->_log('Redirecting to paypal at ' . $paypal_config->{paypal_url} . $token);
    $self->redirect_to( $paypal_config->{paypal_url} . $token );
    return $token;
}

sub _remove_cart_from_session {
    my $self             = shift;
    my $paypal_config    = $self->get_paypal_config;
    my $cart_session_key = $paypal_config->{cart_session_key} || '__CART__';

    #delete cart and token from session_key
    $self->_log('Cart removed from session');
    delete $self->session->{Token} if $self->session->{Token};
    delete $self->session->{$cart_session_key};
    return 1;
}


sub empty_cart {
    my $self = shift;
    $self->_remove_cart_from_session();
    $self->_log('Emptied Cart');
    $self->_do_redirect_or_render();     
}


sub _log {
    my $self    = shift;
    my $caller  = ( caller(1) )[3];
    my $message = __PACKAGE__ . ':' . $caller . ': ' . shift;
    my $logger  = $self->get_logger('paypal');
    return $logger->debug($message);
}

sub do_express_checkout {
    my $self = shift;

    #get paypal config
    my $paypal_config = $self->get_paypal_config;

    #get cart info that was serialized with the token
    my $token = $self->session('Token');
    my $cart  = $self->_get_cart();
    my $total = sprintf( "%.2f", $cart->update_total )
      if ( int( $cart->update_total() ) );

    #token mandatory
    return $self->_transaction_failed(' No Token') unless ($token);
    my $paypal = $self->_get_paypal();

    my %paypal_details = $paypal->send(
        METHOD => 'GetExpressCheckoutDetails',
        TOKEN  => $token
    );
    
    $self->_log('Express Checkout Details ' . Dumper %paypal_details);
    unless ( $paypal_details{ACK} =~ /Success/i ) {
        return $self->_transaction_failed(' GetExpressCheckoutDetails failed ');
    }
    my $user_email = $paypal_details{EMAIL};
    

    my %paypal_request_params = (
        METHOD                         => 'DoExpressCheckoutPayment',
        TOKEN                          => $token,
        PAYMENTREQUEST_0_AMT           => $total,
        PAYMENTREQUEST_0_ITEMAMT       => $total,
        PAYMENTREQUEST_0_PAYMENTACTION => 'Sale',
        PAYERID                        => $paypal_details{PAYERID},

    );
    %paypal_request_params =
      ( %paypal_request_params, $self->_get_paypal_request_options($total) );

    my %payinfo = $paypal->send(%paypal_request_params);

    unless ( $payinfo{ACK} =~ /Success/i ) {
        print Dumper %payinfo;
        return $self->_transaction_failed(' DoExpressCheckoutPayment failed ');
    }
    my $transaction_id = $payinfo{TransactionID};
    $self->_log("Transaction for succcessful for Transaction $transaction_id ");

    my $type = $paypal_config->{payment_record_object};

    require $type . ".pm";
    my %payment_record_map = %{ $paypal_config->{payment_record_map} };
    my %cart_item_map      = %{ $paypal_config->{cart_item_map} };

    #get current user id
    my $user_session_key = $paypal_config->{user_session_key};
    my $payment_record_user_member =
      $paypal_config->{payment_record_user_member};
    my $user_id = $self->session($user_session_key);
    
    my $user_class = $paypal_config->{user_object};
    require $user_class . ".pm";
    my $email_member = $paypal_config->{user_email};
    my $login_member = $paypal_config->{user_login};
    
    print "USEREMAIL $user_email\n\n"; 
    my %where = ($login_member ,$user_id);

    my @tmp  = $user_class->find_by(where =>\%where);
    my $user = $tmp[0]; 

    my %cartItems = %{ $cart->CartItems };
    foreach my $index ( keys(%cartItems) ) {
        my $cartItem = $cartItems{$index};
        my $record   = $type->new;
        my $set_user_method = "set_" . $payment_record_user_member;
        $record->$set_user_method($user);
        foreach my $cartItem_method ( keys(%cart_item_map) ) {

            my $record_member = $cart_item_map{$cartItem_method};
            $record->{$record_member} = $cartItem->$cartItem_method;
        }

        print "\n\nDETAILS\n";
        print Dumper %paypal_details;
        print "\n\n\nResponsse\n";
        print Dumper %payinfo;
        foreach my $paypal_key ( keys(%payment_record_map) ) {
            my $session_key = $token . $paypal_key;
            my $member      = $payment_record_map{$paypal_key};
            $record->{$member} = $payinfo{$paypal_key}
              || $paypal_details{$paypal_key};
        }
        unless ( $record->save() ) {
            $self->_refund_transaction($transaction_id);
            return $self->_transaction_failed(' Record Save Failed');
        }
    }
    my $redirect_to;
    if ( $self->session( $token . "__POSTPAYPALREDIRECT__" ) ) {
        $redirect_to =
          $self->url_with(
            $self->session( $token . "__POSTPAYPALREDIRECT__" ) );
    }
    else {
        $redirect_to =
          $self->url_with( $paypal_config->{payment_complete_route}->{name} );
    }
    $self->_remove_cart_from_session();

    #add the payer email to the session
    $self->session( '__PAYPALPAYER__' => $paypal_details{Payer} );

    if ( $self->req->is_xhr ) {
        $self->render( json => $redirect_to );
    }
    else {
        $self->redirect_to($redirect_to);
    }

}

#public method wrapper
sub refund_transaction {
    my $self = shift;
    my $paypal_config           = $self->get_paypal_config();
    my $message = '';
    
    my $payment_record_object   = $paypal_config->{payment_record_object}; 
    require $payment_record_object . ".pm";   
    my $payment_record_object_pkey_name = $payment_record_object->new()->get_primary_key_name();
    my $record_id = $self->param($payment_record_object_pkey_name);
    if( $record_id ){
        #get record_i
        my $record = $payment_record_object->find($record_id);
        #get transaction id
        my $transaction_id_member  = $paypal_config->{payment_record_map}->{PAYMENTINFO_0_TRANSACTIONID};
        my $transaction_status_member = $paypal_config->{payment_record_map}->{ PAYMENTINFO_0_PAYMENTSTATUS};
        my $status = $record->{$transaction_status_member};
        if ($status ne 'REFUND'){
            my $transaction_id = $record->{$transaction_id_member};
            my $success =  $self->_refund_transaction($transaction_id);     
            if ($success ) {  
                $message = "Transaction $transaction_id has been refunded";
                $record->{$transaction_status_member} = 'REFUND';
                $record->save();
            } else {
                $message = 'REfund failed please check logs';
            }
        }else {
            $message = 'Transaction already refunded';
        }
    }
    else {
         $message = 'Attempt to refund non existing transaction';
        $self->_log($message);
        
    }
    
    my $redirect_to          = $self->url_for("__PAYPALTRANSACTION__")->query([message=>$message]); 
    $self->redirect_to($redirect_to);
}

sub _refund_transaction {
    my $self           = shift;
    my $transaction_id = shift;
    my $paypal         = $self->_get_paypal();

    
    my %paypal_response = $paypal->RefundTransaction(
        TRANSACTIONID => $transaction_id,
        REFUNDTYPE    => 'Full',
        MEMO          => "Please come again!"
    );
    print Dumper %paypal_response;
    if ( $paypal_response{ACK} !~ /Success/i ) {
        for my $error ( @{ $paypal_response{Errors} } ) {
            $self->_log( "Error: " . $error->{LongMessage} . Dumper (%paypal_response) );
        }
        $self->_transaction_failed(
            "Transaction Refund for $transaction_id failed");
        return 0;    
    }
    $self->_log("Refund complete for $transaction_id" . Dumper (%paypal_response));
    return 1;
}

1;
