package Turnaround::Middleware::ActionDispatcher;

use strict;
use warnings;

use base 'Turnaround::Middleware';

use Turnaround::Exception;

sub new {
    my $self = shift->SUPER::new(@_);

    die 'action_factory is required' unless $self->{action_factory};

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

    my $action = $dispatched_request->get_action;
    return unless defined $action;

    $action =
      eval { $self->{action_factory}->build($action, env => $env) } || do {
        my $e = $@;

        $e->rethrow unless $e->does('Turnaround::Exception::ClassNotFound');

        return;
      };

    my $res = $action->run;

    return unless defined $res;

    return [200, ['Content-Type' => 'text/html'], [$res]] unless ref $res;

    return $res  if ref $res eq 'ARRAY';

    return $res if ref $res eq 'CODE';

    return $res->finalize if $res->isa('Turnaround::Response');

    return;
}

1;
