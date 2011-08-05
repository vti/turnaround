package Lamework::Dispatcher::Routes;

use strict;
use warnings;

use base 'Lamework::Dispatcher';

use Lamework::DispatchedRequest::Routes;

sub dispatch {
    my $self = shift;
    my ($path, %args) = @_;

    my $routes = $self->{routes};

    my $m = $routes->match($path, %args);
    return unless $m;

    return $self->_build_dispatched_request(
        routes   => $self->{routes},
        captures => $m->params
    );
}

sub _build_dispatched_request {
    my $self = shift;

    return Lamework::DispatchedRequest::Routes->new(@_);
}


1;
