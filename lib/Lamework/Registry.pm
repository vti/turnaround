package Lamework::Registry;

use strict;
use warnings;

require Carp;

our $REGISTRY = {};

sub instance {
    my $class = shift;

    my $uid;

    if (@_) {
        Carp::croak('Instance UID must be defined or omitted')
          unless defined $_[0];

        $uid = $_[0];
    }
    else {

        # From DBIx::Connector by David E. Wheeler
        $uid = $$;
        $uid = '_' . threads->tid if $INC{'threads.pm'};
    }

    $REGISTRY->{$uid} ||= $class->_new;

    return $REGISTRY->{$uid};
}

sub _new {
    my $class = shift;

    my $self = {@_};
    bless $self, $class;

    return $self;
}

sub get {
    my $self = shift;
    my ($name) = @_;

    my $value = $self->{$name};

    if (ref $value eq 'CODE') {
        $value = $value->();
        $self->set($name => $value);
    }

    return $value;
}

sub set {
    my $self = shift;
    my ($name, $value) = @_;

    $self->{$name} = $value;

    return $self;
}

sub forget {
    my $class = shift;
    my ($uid) = @_;

    delete $REGISTRY->{$uid};

    return $class;
}

1;
