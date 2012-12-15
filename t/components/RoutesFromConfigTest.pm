package RoutesFromConfigTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Turnaround::Routes::FromConfig;

sub add_routes : Test {
    my $self = shift;

    my $routes = $self->_build_routes->load(
        't/components/RoutesFromConfigTest/routes.yml');

    ok($routes->match('/'));
}

sub no_route_when_config_empty : Test {
    my $self = shift;

    my $routes =
      $self->_build_routes->load('t/components/RoutesFromConfigTest/empty.yml');

    ok(!$routes->match('/'));
}

sub _build_routes {
    my $self = shift;

    return Turnaround::Routes::FromConfig->new(@_);
}

1;
