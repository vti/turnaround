package Turnaround::Middleware::RESTActionDispatcher;

use strict;
use warnings;

use base 'Turnaround::Middleware::ActionDispatcher';

use Turnaround::Request;

sub _action {
    my $self = shift;
    my ($env) = @_;

    my $dispatched_request = $env->{'turnaround.dispatched_request'};
    return unless $dispatched_request;

    my $action = $dispatched_request->get_action;
    return unless defined $action;

    $action = $self->_build_action($action, $env);
    return unless defined $action;

    my $http_method = Turnaround::Request->new($env)->param('_method');
    if (!$http_method || $http_method !~ m/^GET|POST|PUT|DELETE|HEAD$/) {
        $http_method = $env->{REQUEST_METHOD};
    }
    $http_method = uc $http_method;

    my $res;
    if ($action->can("method_$http_method")) {
        my $method = "method_$http_method";
        $res = $action->$method;
    }
    elsif ($action->can('method_ALL')) {
        $res = $action->method_ALL;
    }
    else {
        return;
    }

    return $self->{response_resolver}->resolve($res);
}

1;
