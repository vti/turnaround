package Turnaround::Response;

use strict;
use warnings;

use base 'Plack::Response';

sub finalize {
    my $self = shift;

    unless ($self->content_type) {
        $self->content_type('text/html');
    }

    return $self->SUPER::finalize;
}

1;
