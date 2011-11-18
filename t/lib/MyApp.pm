package MyApp;

use strict;
use warnings;

use base 'Lamework';

use Lamework::Home;
use Lamework::Routes;
use Lamework::Dispatcher::Routes;
use Lamework::ActionFactory;
use Lamework::Renderer::Caml;
use Lamework::Displayer;

sub startup {
    my $self = shift;

    $self->{home} = Lamework::Home->new(path => 't');

    $self->add_middleware('RequestDispatcher',
        dispatcher =>
          Lamework::Dispatcher::Routes->new(routes => $self->_build_routes));

    $self->add_middleware(
        'ActionFactory',
        action_factory => Lamework::ActionFactory->new(
            namespace => ref($self) . '::Action::'
        )
    );

    $self->add_middleware(
        'ViewDisplayer',
        displayer => Lamework::Displayer->new(
            renderer => Lamework::Renderer::Caml->new(home => $self->{home})
        )
    );
}

sub _build_routes {
    my $self = shift;

    my $routes = Lamework::Routes->new;
    $routes->add_route('/:action');

    return $routes;
}

1;
