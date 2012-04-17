package Turnaround::FromConfig;

use strict;
use warnings;

use base 'Turnaround::Base';

use Turnaround::Config;

sub BUILD {
    my $self = shift;

    $self->{config} ||= Turnaround::Config->new;
}

sub load {
    my $self = shift;

    my $config = $self->{config}->load(@_);

    return $self->_from_config($config);
}

sub _from_config {
}

1;
