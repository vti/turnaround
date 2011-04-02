package Lamework::Middleware::RoutesDispatcher;

use strict;
use warnings;

use base 'Lamework::Middleware';

use Lamework::Registry;

sub call {
    my $self = shift;
    my ($env) = @_;

    $self->_match($env);

    return $self->app->($env);
}

sub _match {
    my $self = shift;
    my ($env) = @_;

    my $path = $env->{PATH_INFO};

    my $routes = Lamework::Registry->get('routes');

    my $m = $routes->match($path);
    return unless $m;

    $env->{'lamework.routes.match'} = $m;
}

1;
