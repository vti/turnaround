package Turnaround::Helper;

use strict;
use warnings;

use Scalar::Util;
use Turnaround::Request;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{env}      = $params{env};
    $self->{services} = $params{services};

    Scalar::Util::weaken($self->{env});

    return $self;
}

sub service {
    my $self = shift;
    my ($name) = @_;

    return $self->{services}->service($name);
}

sub req {
    my $self = shift;

    $self->{req} ||= Turnaround::Request->new($self->{env});
    Scalar::Util::weaken($self->{req}->{env}); # WTF?

    return $self->{req};
}

sub param {
    my $self = shift;

    return $self->req->param(@_);
}

1;
