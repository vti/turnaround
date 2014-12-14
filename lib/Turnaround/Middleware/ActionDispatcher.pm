package Turnaround::Middleware::ActionDispatcher;

use strict;
use warnings;

use base 'Turnaround::Middleware';

use Carp qw(croak);
use Turnaround::ActionResponseResolver;

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{action_factory} =
         $params{action_factory}
      || $self->{services}->service('action_factory')
      || croak 'action_factory required';
    $self->{response_resolver} = $params{response_resolver};

    $self->{response_resolver} ||= Turnaround::ActionResponseResolver->new;

    return $self;
}

sub call {
    my $self = shift;
    my ($env) = @_;

    my $res = $self->_action($env);
    return $res if $res;

    return $self->app->($env);
}

sub _action {
    my $self = shift;
    my ($env) = @_;

    my $dispatched_request = $env->{'turnaround.dispatched_request'};
    return unless $dispatched_request;

    my $action = $dispatched_request->action;
    return unless defined $action;

    $action = $self->_build_action($action, $env);
    return unless defined $action;

    my $res = $action->run;

    return $self->{response_resolver}->resolve($res);
}

sub _build_action {
    my $self = shift;
    my ($action, $env) = @_;

    my $action_factory = $self->{action_factory};

    return $action_factory->build($action, env => $env);
}

1;
