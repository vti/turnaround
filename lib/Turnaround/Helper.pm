package Turnaround::Helper;

use strict;
use warnings;

use Scalar::Util qw(weaken);

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{env}      = $params{env};
    $self->{services} = $params{services};

    weaken $self->{env};

    return $self;
}

sub service {
    my $self = shift;
    my ($name) = @_;

    return $self->{services}->service($name);
}

sub param {
    my $self = shift;
    my ($key) = @_;

    my $params = $self->{env}->{'turnaround.displayer.vars'}->{params} || {};
    return $params->{$key}->[0] if ref $params->{$key} eq 'ARRAY';
    return $params->{$key};
}

sub param_multi {
    my $self = shift;
    my ($key) = @_;

    my $params = $self->{env}->{'turnaround.displayer.vars'}->{params} || {};
    return $params->{$key} if ref $params->{$key} eq 'ARRAY';
    return [$params->{$key}];
}

1;
