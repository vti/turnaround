package MiddlewareRequestDispatcherTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Lamework::Env;
use Lamework::Routes;
use Lamework::Dispatcher::Routes;
use Lamework::Middleware::RequestDispatcher;

sub do_nothing_when_nothing_dispatched : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;
    my $env = {PATH_INFO => '/', REQUEST_METHOD => 'GET'};

    $mw->call($env);

    ok(!Lamework::Env->new($env)->get('dispatched_request'));
}

sub do_nothing_when_path_info_is_empty : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;
    my $env = {PATH_INFO => '', REQUEST_METHOD => 'GET'};

    $mw->call($env);

    ok(!Lamework::Env->new($env)->get('dispatched_request'));
}

sub dispatch_when_path_found : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;
    my $env = {PATH_INFO => '/foo', REQUEST_METHOD => 'GET'};

    $mw->call($env);

    ok(Lamework::Env->new($env)->get('dispatched_request'));
}

sub do_nothing_when_method_is_wrong : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;
    my $env = {REQUEST_METHOD => 'GET', PATH_INFO => '/only_post'};

    $mw->call($env);

    ok(!Lamework::Env->new($env)->get('dispatched_request'));
}

sub dispatch_when_path_and_method_are_found : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;
    my $env = {REQUEST_METHOD => 'POST', PATH_INFO => '/only_post'};

    $mw->call($env);

    ok(Lamework::Env->new($env)->get('dispatched_request'));
}

sub _build_middleware {
    my $self = shift;

    my $routes = Lamework::Routes->new;
    $routes->add_route('/foo', defaults => {action => 'foo'});
    $routes->add_route(
        '/only_post',
        defaults => {action => 'bar'},
        method   => 'post'
    );

    return Lamework::Middleware::RequestDispatcher->new(
        app => sub { [200, [], ['OK']] },
        dispatcher => Lamework::Dispatcher::Routes->new(routes => $routes)
    );
}

1;
