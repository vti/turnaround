package MyApp;

use strict;
use warnings;

use base 'Lamework';

use Plack::Builder;

use Lamework::Home;
use Lamework::Routes;
use Lamework::Dispatcher::Routes;
use Lamework::ActionBuilder;
use Lamework::Renderer::Caml;
use Lamework::Displayer;

sub startup {
    my $self = shift;

    my $registry = $self->registry;

    $registry->set(home => Lamework::Home->new(path => 't'));
    $registry->set(routes => Lamework::Routes->new);
    $registry->set(
        dispatcher => Lamework::Dispatcher::Routes->new(
            routes => $registry->get('routes')
        )
    );

    my $action_namespace = ref($self) . '::Action::';

    $registry->set(action_builder =>
          Lamework::ActionBuilder->new(app => $self, namespace => $action_namespace));
    $registry->set(renderer =>
          Lamework::Renderer::Caml->new(home => $registry->get('home')));
    $registry->set(
        displayer => Lamework::Displayer->new(
            home     => $registry->get('home'),
            renderer => $registry->get('renderer')
        )
    );

    my $routes = $self->registry->get('routes');

    $routes->add_route('/:action');
}

sub app {
    my $self = shift;

    builder {
        enable '+Lamework::Middleware::MVC',
          dispatcher     => $self->registry->get('dispatcher'),
          action_builder => $self->registry->get('action_builder'),
          displayer      => $self->registry->get('displayer');

        $self->default_app;
    };
}

1;
