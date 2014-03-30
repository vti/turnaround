package MiddlewareActionDispatcherTest;

use strict;
use warnings;

use base 'TestBase';

use lib 't/middleware/MiddlewareActionDispatcherTest';

use Test::More;
use Test::Fatal;

use Turnaround::DispatchedRequest;
use Turnaround::ActionFactory;
use Turnaround::Middleware::ActionDispatcher;

sub do_nothing_when_no_action : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;

    my $res = $mw->call($self->_build_env);

    is_deeply($res, [200, [], ['OK']]);
}

sub do_nothing_when_unknown_action : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;

    my $res = $mw->call($self->_build_env(action => 'unknown'));

    is_deeply($res, [200, [], ['OK']]);
}

sub skip_when_no_response : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;

    my $res = $mw->call($self->_build_env(action => 'no_response'));

    is_deeply($res, [200, [], ['OK']]);
}

sub run_action_with_custom_response : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;

    my $res = $mw->call($self->_build_env(action => 'custom_response'));

    is_deeply $res =>
      [200, ['Content-Type' => 'text/html'], ['Custom response!']];
}

sub run_action_with_text_response : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;

    my $res = $mw->call($self->_build_env(action => 'text_response'));

    is_deeply $res =>
      [200, ['Content-Type' => 'text/html'], ['Text response!']];
}

sub _build_middleware {
    my $self = shift;
    my (%params) = @_;

    return Turnaround::Middleware::ActionDispatcher->new(
        action_factory => Turnaround::ActionFactory->new(),
        app => sub { [200, [], ['OK']] }
    );
}

sub _build_env {
    my $self = shift;
    my (%params) = @_;

    my $env =
      {'turnaround.dispatched_request' =>
          Turnaround::DispatchedRequest->new(action => delete $params{action})};

    foreach my $key (keys %params) {
        $env->{"turnaround.$key"} = $params{$key};
    }

    return $env;
}

1;
