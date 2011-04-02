package Lamework::Logger;

use strict;
use warnings;

sub new {
    my $class = shift;

    my $self = {@_};
    bless $self, $class;

    $self->{logger} ||= sub { };

    return $self;
}

sub debug {
    my $self = shift;
    my ($message) = @_;

    $self->{logger}->({level => 'debug', message => $message});
}

1;
