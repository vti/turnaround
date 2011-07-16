package Lamework::Middleware::RoutesDispatcher;

use strict;
use warnings;

use base 'Lamework::Middleware';

sub call {
    my $self = shift;
    my ($env) = @_;

    $self->_match($env);

    return $self->app->($env);
}

sub _match {
    my $self = shift;
    my ($env) = @_;

    my $path   = $env->{PATH_INFO};
    my $method = $env->{REQUEST_METHOD};

    my $routes = $env->{'lamework.ioc'}->get_service('routes');

    my $m = $routes->match($path, method => lc $method);
    return unless $m;

    $env->{'lamework.captures'} = $m->params;
    $env->{'lamework.match'}    = $m;

    return $self;
}

1;
