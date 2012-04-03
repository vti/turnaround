package Lamework::SimpleApp;

use strict;
use warnings;

use base 'Lamework';

use Lamework::ActionFactory;
use Lamework::Dispatcher::Routes;
use Lamework::Displayer;
use Lamework::Home;
use Lamework::Renderer::Caml;
use Lamework::Routes;

sub startup {
    my $self = shift;

    my $displayer =
      Lamework::Displayer->new(
        renderer => Lamework::Renderer::Caml->new(home => $self->{home}));

    $self->add_middleware('HTTPExceptions');

    $self->add_middleware('RequestDispatcher',
        dispatcher =>
          Lamework::Dispatcher::Routes->new(routes => $self->_build_routes));

    $self->add_middleware(
        'ActionDispatcher',
        action_factory => Lamework::ActionFactory->new(
            namespace => ref($self) . '::Action::'
        )
    );

    $self->add_middleware('ViewDisplayer', displayer => $displayer);
}

sub _build_routes {
    my $self = shift;

    return Lamework::Routes->new;
}

1;
