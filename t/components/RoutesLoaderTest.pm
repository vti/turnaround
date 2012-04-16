package RoutesLoaderTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Turnaround::Routes::Loader;

sub add_routes : Test {
    my $self = shift;

    my $routes =
      $self->_build_routes->load('t/components/RoutesLoaderTest/routes.yml');

    ok($routes->match('/'));
}

sub no_route_when_config_empty : Test {
    my $self = shift;

    my $routes =
      $self->_build_routes->load('t/components/RoutesLoaderTest/empty.yml');

    ok(!$routes->match('/'));
}

sub throw_when_no_file : Test {
    my $self = shift;

    like(
        exception {
            $self->_build_routes->load('t/components/RoutesLoaderTest/unknown.yml');
        },
        qr/file '.*?unknown\.yml' does not exist/i
    );
}

sub throw_on_wrong_config : Test {
    my $self = shift;

    like(
        exception {
            $self->_build_routes->load('t/components/RoutesLoaderTest/bad.yml');
        },
        qr/YAML::Tiny failed to classify line 'bad file'/
    );
}

sub _build_routes {
    my $self = shift;

    return Turnaround::Routes::Loader->new(@_);
}

1;
