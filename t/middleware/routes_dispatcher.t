use strict;
use warnings;

use Test::More tests => 4;

use_ok('Lamework::Middleware::RoutesDispatcher');

use Lamework::Registry;
use Lamework::Routes;

my $routes = Lamework::Routes->new();
$routes->add_route('/foo', defaults => {action => 'foo'});
Lamework::Registry->set('routes' => $routes);

my $middleware = Lamework::Middleware::RoutesDispatcher->new(app => sub {});

my $env = {PATH_INFO => '/'};
$middleware->call($env);
ok(not exists $env->{'lamework.routes.match'});

$env = {PATH_INFO => ''};
$middleware->call($env);
ok(not exists $env->{'lamework.routes.match'});

$env = {PATH_INFO => '/foo'};
$middleware->call($env);
ok($env->{'lamework.routes.match'});
