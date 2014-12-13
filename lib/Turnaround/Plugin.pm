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

sub home     { $_[0]->{home} }
sub services { $_[0]->{services} }
sub builder  { $_[0]->{builder} }

sub startup { }

sub run { }

1;
