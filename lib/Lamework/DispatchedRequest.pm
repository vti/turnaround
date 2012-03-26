package Lamework::DispatchedRequest;

use strict;
use warnings;

use base 'Lamework::Base';

require Carp;

sub build_path { Carp::croak('Not implemented') }

sub set_action {
    my $self = shift;
    my ($action, $value) = @_;

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
    my ($captures, $value) = @_;

    $self->{captures} = $value;

    return $self;
}

sub get_captures {
    my $self = shift;
    my ($captures) = @_;

    return $self->{captures};
}

1;
