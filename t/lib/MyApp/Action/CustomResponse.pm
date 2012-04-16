package MyApp::Action::CustomResponse;

use strict;
use warnings;

use base 'Turnaround::Action';

sub run {
    my $self = shift;

    $self->res->code(200);
    $self->res->body('Custom response!');
}

1;
