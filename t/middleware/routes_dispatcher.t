use strict;
use warnings;

use Test::More tests => 6;

use_ok('Lamework::Middleware::RoutesDispatcher');

use Lamework::IOC;
use Lamework::Routes;

my $routes = Lamework::Routes->new;
$routes->add_route('/foo', defaults => {action => 'foo'});
$routes->add_route(
    '/only_post',
    defaults => {action => 'bar'},
    method   => 'post'
);

my $ioc = Lamework::IOC->new;
$ioc->register(routes => $routes);

my $middleware = Lamework::Middleware::RoutesDispatcher->new(app => sub { });

my $env = {PATH_INFO => '/', 'lamework.ioc' => $ioc};
$middleware->call($env);
ok !$env->{'lamework.match'};

$env = {PATH_INFO => '', 'lamework.ioc' => $ioc};
$middleware->call($env);
ok !$env->{'lamework.match'};

$env = {PATH_INFO => '/foo', 'lamework.ioc' => $ioc};
$middleware->call($env);
ok $env->{'lamework.match'};

$env = {
    REQUEST_METHOD => 'GET',
    PATH_INFO      => '/only_post',
    'lamework.ioc' => $ioc
};
$middleware->call($env);
ok !$env->{'lamework.match'};

$env = {
    REQUEST_METHOD => 'POST',
    PATH_INFO      => '/only_post',
    'lamework.ioc' => $ioc
};
$middleware->call($env);
ok $env->{'lamework.match'};
