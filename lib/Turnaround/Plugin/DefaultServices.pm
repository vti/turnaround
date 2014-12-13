package Turnaround::Plugin::DefaultServices;

use strict;
use warnings;

use base 'Turnaround::Plugin';

use Scalar::Util qw(weaken);
use Turnaround::HelperFactory::Persistent;
use Turnaround::Request;
use Turnaround::Config;
use Turnaround::Routes::FromConfig;
use Turnaround::Dispatcher::Routes;
use Turnaround::Displayer;
use Turnaround::Renderer::APL;
use Turnaround::ActionFactory;

sub startup {
    my $self = shift;

    my $home     = $self->home;
    my $services = $self->services;

    $services->register(home => $home);

    my $config_loader =
      $self->{config_loader} || Turnaround::Config->new(mode => 1);
    $services->register(config => $config_loader->load('config/config.yml'));

    my $routes = Turnaround::Routes::FromConfig->new->load('config/routes.yml');
    $services->register(routes => $routes);

    $services->register(
        dispatcher => Turnaround::Dispatcher::Routes->new(routes => $routes));

    $services->register(
        action_factory => Turnaround::ActionFactory->new(
            namespaces => $self->{app_class} . '::Action::'
        )
    );

    my $displayer = Turnaround::Displayer->new(
        renderer => Turnaround::Renderer::APL->new(home => $home),
        layout   => 'layout.apl'
    );
    $services->register(displayer => $displayer);

    $self->{builder}->add_middleware(
        'ErrorDocument',
        403        => '/forbidden',
        404        => '/not_found',
        subrequest => 1
    );

    $self->builder->add_middleware('HTTPExceptions', services => $services);

    my $public_dir = $home->catfile('public');
    my @dirs =
      map { s/^$public_dir\/?//; $_ } grep { -d $_ } glob "$public_dir/*";
    my $re = '^/(?:' . join('|', @dirs) . ')/';
    $self->builder->add_middleware(
        'Static',
        path => qr/$re/,
        root => $self->{home}->catfile('public')
    );

    $self->builder->add_middleware('RequestDispatcher', services => $services);
    $self->builder->add_middleware('ActionDispatcher',  services => $services);
    $self->builder->add_middleware('ViewDisplayer',     services => $services);

    return $self;
}

sub run {
    my $self = shift;
    my ($env) = @_;

    weaken($env);

    $env->{'turnaround.displayer.vars'}->{'mode'} =
      $ENV{PLACK_ENV} || 'production';

    $env->{'turnaround.displayer.vars'}->{'helpers'} =
      Turnaround::HelperFactory::Persistent->new(
        namespaces => $self->{app_class} . '::Helper::',
        services   => $self->{services},
        env        => $env
      );

    return $self;
}

1;
