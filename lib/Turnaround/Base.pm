package Turnaround::Base;

use strict;
use warnings;

sub new {
    my $class = shift;
    $class = ref $class if ref $class;

    my $self = { $class->BUILD_ARGS(@_) };
    bless $self, $class;

    $self->BUILD;

    return $self;
}

sub BUILD_ARGS {
    my $class = shift;

    return @_;
}

sub BUILD {
}

1;
