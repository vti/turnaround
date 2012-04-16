package MiddlewareRequestDispatcherTest;

use strict;
use warnings;
use utf8;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Turnaround::Routes;
use Turnaround::Dispatcher::Routes;
use Turnaround::Middleware::RequestDispatcher;

sub throw_404_when_nothing_dispatched : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;
    my $env = {PATH_INFO => '/', REQUEST_METHOD => 'GET'};

    isa_ok(exception {$mw->call($env)}, 'Turnaround::HTTPException');
}

sub throw_404_when_path_info_is_empty : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;
    my $env = {PATH_INFO => '', REQUEST_METHOD => 'GET'};

    isa_ok(exception {$mw->call($env)}, 'Turnaround::HTTPException');
}

sub dispatch_when_path_found : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;
    my $env = {PATH_INFO => '/foo', REQUEST_METHOD => 'GET'};

    $mw->call($env);

    ok($env->{'turnaround.dispatched_request'});
}

sub do_nothing_when_method_is_wrong : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;
    my $env = {REQUEST_METHOD => 'GET', PATH_INFO => '/only_post'};

    isa_ok(exception {$mw->call($env)}, 'Turnaround::HTTPException');
}

sub dispatch_when_path_and_method_are_found : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;
    my $env = {REQUEST_METHOD => 'POST', PATH_INFO => '/only_post'};

    $mw->call($env);

    ok($env->{'turnaround.dispatched_request'});
}

sub dispatch_utf_path : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;
    my $env = {
        REQUEST_METHOD => 'GET',
        PATH_INFO => '/unicode/' . Encode::encode('UTF-8', 'привет')
    };

    $mw->call($env);

    is($env->{'turnaround.dispatched_request'}->{captures}->{name}, 'привет');
}

sub _build_middleware {
    my $self = shift;

    my $routes = Turnaround::Routes->new;
    $routes->add_route('/foo', defaults => {action => 'foo'});
    $routes->add_route(
        '/only_post',
        defaults => {action => 'bar'},
        method   => 'post'
    );
    $routes->add_route('/unicode/:name', name => 'bar');

    return Turnaround::Middleware::RequestDispatcher->new(
        app => sub { [200, [], ['OK']] },
        dispatcher => Turnaround::Dispatcher::Routes->new(routes => $routes)
    );
}

1;
