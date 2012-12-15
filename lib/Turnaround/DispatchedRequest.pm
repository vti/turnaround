package Turnaround::DispatchedRequest;

use strict;
use warnings;

require Carp;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{action}   = $params{action};
    $self->{captures} = $params{captures};

    return $self;
}

sub build_path { Carp::croak('Not implemented') }

sub set_action {
    my $self = shift;
    my ($value) = @_;

    $self->{action} = $value;

    return $self;
}

sub get_action {
    my $self = shift;
    my ($action) = @_;

    return $self->{action};
}

sub set_captures {
    my $self = shift;
    my ($value) = @_;

    $self->{captures} = $value;

    return $self;
}

sub get_captures {
    my $self = shift;
    my ($captures) = @_;

    return $self->{captures};
}

1;
