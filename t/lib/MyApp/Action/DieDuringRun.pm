package MyApp::Action::DieDuringRun;

use strict;
use warnings;

use base 'Lamework::Action';

sub run {
    my $self = shift;

    die 'here';
}

1;
