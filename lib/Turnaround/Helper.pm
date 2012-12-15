package Turnaround::Helper;

use strict;
use warnings;

use Turnaround::Request;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{env} = $params{env};

    return $self;
}

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
