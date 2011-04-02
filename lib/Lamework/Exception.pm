package Lamework::Exception;

use strict;
use warnings;

require Carp;

sub new {
    my $class = shift;

    my $self = {@_};
    bless $self, $class;

    return $self;
}

sub error { shift->{error} }

sub throw {
    my $class = shift;
    my ($error) = @_;

    Carp::croak($class->new(error => $error));
}

1;
