package Lamework::HTTPException;

use strict;
use warnings;

use base 'Lamework::Base';

require Carp;

sub code { shift->{code} }

sub location { shift->{location} }

sub throw {
    my $class = shift;
    my $code  = shift;

    Carp::croak($class->new(code => $code, @_));
}

sub as_string { shift->{message} }

1;
