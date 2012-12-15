package Turnaround::Logger;

use strict;
use warnings;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{logger} = $params{logger};

    $self->{logger} ||= sub { };

    return $self;
}

sub debug {
    my $self = shift;
    my ($message) = @_;

    $self->{logger}->({level => 'debug', message => $message});
}

1;
