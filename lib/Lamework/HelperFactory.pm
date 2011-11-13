package Lamework::HelperFactory;

use strict;
use warnings;

use base 'Lamework::Factory';

our $AUTOLOAD;

sub DESTROY { }

sub AUTOLOAD {
    my $self = shift;

    my ($method) = (split /::/, $AUTOLOAD)[-1];

    return if $method =~ /[A-Z]/;

    return $self->build($method);
}

1;
