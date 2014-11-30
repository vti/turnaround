package Turnaround::Plugin;

use strict;
use warnings;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{app_class} = $params{app_class};
    $self->{home}      = $params{home};
    $self->{services}  = $params{services};
    $self->{builder}   = $params{builder};

    return $self;
}

sub startup { }

sub run { }

1;
