package Lamework::HTTPException;

use strict;
use warnings;

require Carp;

sub new {
    my $class = shift;

    my $self = {@_};
    bless $self, $class;

    return $self;
}

sub code { shift->{code} }

sub location { shift->{location} }

sub throw {
    my $class = shift;
    my $code  = shift;

    Carp::croak($class->new(code => $code, @_));
}

sub as_string { shift->{message} }

1;
