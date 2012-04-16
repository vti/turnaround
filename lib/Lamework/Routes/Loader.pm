package Lamework::Routes::Loader;

use strict;
use warnings;

use base 'Lamework::Base';

use YAML::Tiny;
use Lamework::Routes;

sub BUILD {
    my $self = shift;

    $self->{routes} ||= Lamework::Routes->new;
}

sub load {
    my $self = shift;
    my ($config) = @_;

    die 'File not found' unless -f $config;

    my $routes = $self->{routes};

    my $yaml = YAML::Tiny->read($config);

    foreach my $route (@{$yaml->[0]}) {
        $routes->add_route(delete $route->{route}, %$route);
    }

    return $routes;
}

1;
