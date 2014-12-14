use strict;
use warnings;

use Test::More;

use Turnaround::Routes::FromConfig;

subtest 'add_routes' => sub {
    my $routes = _build_routes()->load('t/routes/from_config_t/routes.yml');

    ok $routes->match('/');
};

subtest 'no_route_when_config_empty' => sub {
    my $routes = _build_routes()->load('t/routes/from_config_t/empty.yml');

    ok !$routes->match('/');
};

sub _build_routes { Turnaround::Routes::FromConfig->new(@_) }

done_testing;
