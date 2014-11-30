package Turnaround::Helper::Assets;

use strict;
use warnings;

use base 'Turnaround::Helper';

use Turnaround::AssetsContainer;

sub include {
    my $self = shift;

    return $self->_container->include(@_);
}

sub require {
    my $self = shift;

    $self->_container->require(@_);

    return $self;
}

sub _container {
    my $self = shift;

    $self->{container} ||= Turnaround::AssetsContainer->new;

    return $self->{container};
}

1;
