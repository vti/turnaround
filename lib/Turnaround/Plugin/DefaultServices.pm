package Turnaround::Plugin::DefaultServices;

use strict;
use warnings;

use base 'Turnaround::Plugin';

use Turnaround::Config;
use Turnaround::Routes::FromConfig;
use Turnaround::Dispatcher::Routes;
use Turnaround::Displayer;
use Turnaround::Renderer::APL;
use Turnaround::ActionFactory;

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{config_loader} = $params{config_loader};

    return $self;
}

sub startup {
    my $self = shift;

    my $home     = $self->{home};
    my $services = $self->{services};

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

    return $self;
}

1;
