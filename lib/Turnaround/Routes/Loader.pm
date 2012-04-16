package Turnaround::Routes::Loader;

use strict;
use warnings;

use base 'Turnaround::Base';

use YAML::Tiny;
use Turnaround::Routes;

sub BUILD {
    my $self = shift;

    $self->{routes} ||= Turnaround::Routes->new;
}

sub load {
    my $self = shift;
    my ($config) = @_;

    my $routes = $self->{routes};

    my $yaml = YAML::Tiny->read($config) or die $YAML::Tiny::errstr;

    foreach my $route (@{$yaml->[0]}) {
        $routes->add_route(delete $route->{route}, %$route);
    }

    return $routes;
}

1;
