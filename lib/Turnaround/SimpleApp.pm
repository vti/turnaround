package Turnaround::SimpleApp;

use strict;
use warnings;

use base 'Turnaround';

use Turnaround::ActionFactory;
use Turnaround::Dispatcher::Routes;
use Turnaround::Displayer;
use Turnaround::Home;
use Turnaround::Renderer::Caml;
use Turnaround::Routes;

sub startup {
    my $self = shift;

    my $displayer =
      Turnaround::Displayer->new(
        renderer => Turnaround::Renderer::Caml->new(home => $self->{home}));

    $self->add_middleware('HTTPExceptions');

    $self->add_middleware('RequestDispatcher',
        dispatcher =>
          Turnaround::Dispatcher::Routes->new(routes => $self->_build_routes));

    $self->add_middleware(
        'ActionDispatcher',
        action_factory => Turnaround::ActionFactory->new(
            namespaces => ref($self) . '::Action::'
        )
    );

    $self->add_middleware('ViewDisplayer', displayer => $displayer);
}

sub _build_routes {
    my $self = shift;

    return Turnaround::Routes->new;
}

1;
