package Lamework::HTTPException;

use strict;
use warnings;

use base 'Lamework::Exception';

require Carp;

sub code { $_[0]->{code} }

sub location { $_[0]->{location} }

sub throw {
    my $class = shift;
    my $code  = shift;

    my $message = '';

    if (@_ == 1) {
        $message = shift;
    }

    Carp::croak($class->new(code => $code, message => $message, @_));
}

1;
