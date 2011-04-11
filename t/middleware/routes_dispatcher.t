use strict;
use warnings;

use Test::More tests => 6;

use_ok('Lamework::Middleware::RoutesDispatcher');

use Lamework::Registry;
use Lamework::Routes;

my $routes = Lamework::Routes->new();
$routes->add_route('/foo', defaults => {action => 'foo'});
$routes->add_route(
    '/only_post',
    defaults => {action => 'bar'},
    method   => 'post'
);
Lamework::Registry->set('routes' => $routes);

my $middleware = Lamework::Middleware::RoutesDispatcher->new(app => sub { });

my $env = {PATH_INFO => '/'};
$middleware->call($env);
ok(not exists $env->{'lamework.routes.match'});

$env = {PATH_INFO => ''};
$middleware->call($env);
ok(not exists $env->{'lamework.routes.match'});

$env = {PATH_INFO => '/foo'};
$middleware->call($env);
ok($env->{'lamework.routes.match'});

$env = {REQUEST_METHOD => 'GET', PATH_INFO => '/only_post'};
$middleware->call($env);
ok(!$env->{'lamework.routes.match'});

$env = {REQUEST_METHOD => 'POST', PATH_INFO => '/only_post'};
$middleware->call($env);
ok($env->{'lamework.routes.match'});
