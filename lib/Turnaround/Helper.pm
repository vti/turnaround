package Turnaround::Helper;

use strict;
use warnings;

use base 'Turnaround::Base';

use Turnaround::Request;

sub req {
    my $self = shift;

    $self->{req} ||= Turnaround::Request->new($self->{env});

    return $self->{req};
}

sub param {
    my $self = shift;

    return $self->req->param(@_);
}

1;
