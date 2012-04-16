package Turnaround::Validator::Regexp;

use strict;
use warnings;

use base 'Turnaround::Validator::Base';

sub is_valid {
    my $self = shift;
    my ($value, $re) = @_;

    return $value =~ m/$re/;
}

1;
