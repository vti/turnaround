package Lamework::Middleware::Core;

use strict;
use warnings;

use base 'Lamework::Middleware';

use Plack::Middleware::HTTPExceptions;

sub wrap {
    my $self = shift;
    my ($app, %args) = @_;

    $app = Plack::Middleware::HTTPExceptions->new({app => $app})->to_app;

    return $self->SUPER::wrap($app, %args);
}

sub call {
    my $self = shift;
    my ($env) = @_;

    $env->{'lamework.ioc'} = $self->{ioc};

    return $self->app->($env);
}

1;
