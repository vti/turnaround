package Turnaround::Dispatcher::Routes;

use strict;
use warnings;

use base 'Turnaround::Dispatcher';

use Turnaround::DispatchedRequest::Routes;

sub dispatch {
    my $self = shift;
    my ($path, %args) = @_;

    my $routes = $self->{routes};

    my $m = $routes->match($path, %args);
    return unless $m;

    my $action = $m->params->{action} || $m->name;
    die "Action is unknown. Nor 'action' neither ->name was declared"
      unless $action;

    return $self->_build_dispatched_request(
        action   => $action,
        routes   => $self->{routes},
        captures => $m->params
    );
}

sub _build_dispatched_request {
    my $self = shift;

    return Turnaround::DispatchedRequest::Routes->new(@_);
}

1;
