package Lamework::Middleware::RequestDispatcher;

use strict;
use warnings;

use base 'Lamework::Middleware';

sub call {
    my $self = shift;
    my ($env) = @_;

    $self->_dispatch($env);

    return $self->app->($env);
}

sub _dispatch {
    my $self = shift;
    my ($env) = @_;

    my $path   = $env->{PATH_INFO};
    my $method = $env->{REQUEST_METHOD};

    my $dispatcher = $self->{dispatcher} or die 'dispatcher required';

    my $dispatched_request = $dispatcher->dispatch($path, method => lc $method);
    return unless $dispatched_request;

    $env->{'lamework.dispatched_request'} = $dispatched_request;
}

1;
