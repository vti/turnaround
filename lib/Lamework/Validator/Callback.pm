package Lamework::Validator::Callback;

use strict;
use warnings;

use base 'Lamework::Validator::Base';

sub is_valid {
    my $self = shift;
    my ($value, $cb) = @_;

    return $cb->($self, $value);
}

1;
