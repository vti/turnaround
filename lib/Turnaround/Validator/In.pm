package Turnaround::Validator::In;

use strict;
use warnings;

use base 'Turnaround::Validator::Base';

sub is_valid {
    my $self = shift;
    my ($value, $in) = @_;

    return !!grep { $value eq $_ } @$in;
}

1;
