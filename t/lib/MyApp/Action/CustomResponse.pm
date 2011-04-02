package MyApp::Action::CustomResponse;

use strict;
use warnings;

use base 'Lamework::Action';

sub run {
    my $self = shift;

    $self->res->code(200);
    $self->res->body('Custom response!');
}

1;
