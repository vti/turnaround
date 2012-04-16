package Turnaround::Validator::Compare;

use strict;
use warnings;

use base 'Turnaround::Validator::Base';

sub is_valid {
    my $self = shift;
    my ($values) = @_;

    for (@$values[1 .. $#$values]) {
        return 0 unless $_ eq $values->[0];
    }

    return 1;
}

1;
