use strict;
use warnings;

use Test::More tests => 6;

use_ok('Lamework::Middleware::RequestDispatcher');

use Lamework::Routes;
use Lamework::Dispatcher::Routes;

my $routes = Lamework::Routes->new;
$routes->add_route('/foo', defaults => {action => 'foo'});
$routes->add_route(
    '/only_post',
    defaults => {action => 'bar'},
    method   => 'post'
);

my $middleware = Lamework::Middleware::RequestDispatcher->new(
    app        => sub                                      { },
    dispatcher => Lamework::Dispatcher::Routes->new(routes => $routes)
);

my $env = {PATH_INFO => '/', REQUEST_METHOD => 'GET'};
$middleware->call($env);
ok !$env->{'lamework.dispatched_request'};

$env = {PATH_INFO => '', REQUEST_METHOD => 'GET'};
$middleware->call($env);
ok !$env->{'lamework.dispatched_request'};

$env = {PATH_INFO => '/foo', REQUEST_METHOD => 'GET'};
$middleware->call($env);
ok $env->{'lamework.dispatched_request'};

$env = {
    REQUEST_METHOD => 'GET',
    PATH_INFO      => '/only_post'
};
$middleware->call($env);
ok !$env->{'lamework.dispatched_request'};

$env = {
    REQUEST_METHOD => 'POST',
    PATH_INFO      => '/only_post'
};
$middleware->call($env);
ok $env->{'lamework.dispatched_request'};
