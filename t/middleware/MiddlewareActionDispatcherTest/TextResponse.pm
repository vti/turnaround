package TextResponse;

use strict;
use warnings;

use base 'Turnaround::Action';

sub run {
    my $self = shift;

    return 'Text response!';
}

1;
