package Lamework::Config;

use strict;
use warnings;

use base 'Lamework::Base';

sub config {
    my $self = shift;

    $self->{config} ||= $self->{loader}->load;

    return $self->{config};
}

sub load {
    my $self = shift;

    return $self->{loader}->load(@_);
}

1;
