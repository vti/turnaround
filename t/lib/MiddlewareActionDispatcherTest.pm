package MiddlewareActionDispatcherTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Lamework::DispatchedRequest;
use Lamework::ActionFactory;
use Lamework::Middleware::ActionDispatcher;

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

sub run_action : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;

    my $res = $mw->call($self->_build_env(action => 'foo'));

    is_deeply($res, [200, [], ['OK']]);
}

sub run_action_with_custom_response : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;

    my $res = $mw->call($self->_build_env(action => 'custom_response'));

    is_deeply $res =>
      [200, ['Content-Type' => 'text/html'], ['Custom response!']];
}

sub _build_middleware {
    my $self = shift;
    my (%params) = @_;

    return Lamework::Middleware::ActionDispatcher->new(
        action_factory =>
          Lamework::ActionFactory->new(namespace => 'MyApp::Action::'),
        app => sub { [200, [], ['OK']] }
    );
}

sub _build_env {
    my $self = shift;
    my (%params) = @_;

    my $env =
      {'lamework.dispatched_request' =>
          Lamework::DispatchedRequest->new(action => $params{action})};

    foreach my $key (keys %params) {
        $env->{"lamework.$key"} = $params{$key};
    }

    return $env;
}

1;
