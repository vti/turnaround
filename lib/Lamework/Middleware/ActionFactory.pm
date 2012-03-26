package Lamework::Middleware::ActionFactory;

use strict;
use warnings;

use base 'Lamework::Middleware';

use Lamework::Env;
use Lamework::Exception;

sub new {
    my $self = shift->SUPER::new(@_);

    die 'action_factory is required' unless $self->{action_factory};

    return $self;
}

sub call {
    my $self = shift;
    my ($env) = @_;

    my $res = $self->_action(Lamework::Env->new($env));
    return $res if $res;

    return $self->app->($env);
}

sub _action {
    my $self = shift;
    my ($env) = @_;

    my $dispatched_request = $env->get('dispatched_request');
    return unless $dispatched_request;

    my $action = $dispatched_request->get_action;
    return unless defined $action;

    $action = try {
        $self->{action_factory}->build($action, env => $env);
    }
    catch {
        $_->rethrow unless $_->does('Lamework::Exception::ClassNotFound');

        return;
    };
    return unless defined $action;

    $action->run;

    if ($action->response_cb) {
        return $action->response_cb;
    }

    if ($action->res->code || defined $action->res->body) {
        return $action->res->finalize;
    }

    return;
}

1;
