package Mixin;

use strict;
use warnings;

use base 'Turnaround::Mixin';

sub public {
    'public';
}

sub BEFORE_modified_before {
    my $self = shift;

    die if @_;
}

sub AROUND_modified_around {
    my $self = shift;
    my ($orig, @args) = @_;

    return 'before' . $self->$orig(@args) . 'after';
}

sub _private {
    'private';
}

1;
