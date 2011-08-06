package Lamework::Middleware::ActionBuilder;

use strict;
use warnings;

use base 'Lamework::Middleware';

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

    my $dispatched_request = $env->{'lamework.dispatched_request'};
    return unless $dispatched_request;

    my $action = $dispatched_request->captures->{action};
    return unless defined $action;

    $action = $self->{action_builder}->build($action, $env);
    return unless defined $action;

    my $retval = $action->run;
    return $retval if ref $retval eq 'CODE' || ref $retval eq 'ARRAY';

    if ($action->res->code || defined $action->res->body) {
        return $action->res->finalize;
    }

    return;
}

1;
