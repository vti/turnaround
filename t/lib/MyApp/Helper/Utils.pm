package MyApp::Helper::Utils;

use strict;
use warnings;

use base 'Turnaround::Helper';

sub path_info {
    my $self = shift;

    return $self->{env}->{PATH_INFO};
}

1;
