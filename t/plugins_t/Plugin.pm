package Plugin;

use strict;
use warnings;

use base 'Turnaround::Plugin';

sub run {
    my $self = shift;
    my ($env) = @_;

    $env->{foo} = 'bar';
}

1;
