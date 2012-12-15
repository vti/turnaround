package Turnaround::Dispatcher;

use strict;
use warnings;

require Carp;

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub dispatch { Carp::croak('Not implemented') }

1;
