package MyApp;

use strict;
use warnings;

use base 'Turnaround';

use Turnaround::Home;
use Turnaround::Routes;
use Turnaround::Renderer::Caml;

sub startup {
    my $self = shift;

    $self->{home} = Turnaround::Home->new(path => 't/functional_tests');

    $self->register_plugin(
        'DefaultServices',
        config   => {},
        routes   => $self->_build_routes,
        renderer => Turnaround::Renderer::Caml->new(home => $self->{home}),
        layout   => ''
    );

    return $self;
}

sub _build_routes {
    my $self = shift;

    my $routes = Turnaround::Routes->new;
    $routes->add_route('/:action');

    return $routes;
}

1;
