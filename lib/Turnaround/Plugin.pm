package Turnaround::Plugin;

use strict;
use warnings;

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub startup { }

sub run { }

1;
