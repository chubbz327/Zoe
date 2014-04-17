package Zoe::ObjectMeta;
use Mojo::Base -strict;


sub new {

    
    my $class = shift; 
      my %arg  = @_;
    my $self = {
        has_many           => {},
        many_to_many       => {},
        foreign_key_feilds => {},
        columns            => [],
        type               => undef,
        primary_key        => undef,
        num_foreign_keys   => 0,
        to_string_member   => 0,
        object             => undef,

        %arg
    };

    return bless $self, $class;
}

1;
__DATA__

=head1 NAME

ZOE::ObjectMeta

=head1 Description

Used by Zoe to store object information prior to generating the MVC code and database tables

=head1 Author
	
dinnibartholomew@gmail.com
	

=cut
