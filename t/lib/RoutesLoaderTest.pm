package RoutesLoaderTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Lamework::Routes::Loader;

sub add_routes : Test {
    my $self = shift;

    my $routes = $self->_build_routes->load('t/lib/RoutesLoaderTest/routes.yml');

    ok($routes->match('/'));
}

sub no_route_when_config_empty : Test {
    my $self = shift;

    my $routes = $self->_build_routes->load('t/lib/RoutesLoaderTest/empty.yml');

    ok(!$routes->match('/'));
}

sub throw_when_no_file : Test {
    my $self = shift;

    ok(exception {$self->_build_routes->load('t/lib/RoutesLoaderTest/unknown.yml')});
}

sub throw_on_wrong_config : Test {
    my $self = shift;

    ok(exception {$self->_build_routes->load('t/lib/RoutesLoaderTest/bad.yml')});
}

sub _build_routes {
    my $self = shift;

    return Lamework::Routes::Loader->new(@_);
}

1;
