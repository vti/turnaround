package Turnaround::DispatchedRequest;

use strict;
use warnings;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{action}   = $params{action};
    $self->{captures} = $params{captures};

    return $self;
}

sub build_path { ... }

sub action {
    my $self = shift;
    my ($action) = @_;

    return $self->{action};
}

sub captures {
    my $self = shift;
    my ($captures) = @_;

    return $self->{captures};
}

1;
