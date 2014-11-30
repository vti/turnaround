use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Turnaround::Routes::FromConfig;

subtest 'add_routes' => sub {
    my $routes =
      _build_routes()->load('t/components/RoutesFromConfigTest/routes.yml');

    ok($routes->match('/'));
};

subtest 'no_route_when_config_empty' => sub {
    my $routes =
      _build_routes()->load('t/components/RoutesFromConfigTest/empty.yml');

    ok(!$routes->match('/'));
};

sub _build_routes {
    return Turnaround::Routes::FromConfig->new(@_);
}

done_testing;
