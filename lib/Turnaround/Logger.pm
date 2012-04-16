package Turnaround::Logger;

use strict;
use warnings;

use base 'Turnaround::Base';

sub BUILD {
    my $self = shift;

    $self->{logger} ||= sub { };

    return $self;
}

sub debug {
    my $self = shift;
    my ($message) = @_;

    $self->{logger}->({level => 'debug', message => $message});
}

1;
