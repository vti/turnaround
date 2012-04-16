package MyApp;

use strict;
use warnings;

use base 'Turnaround::SimpleApp';

use Turnaround::Home;
use Turnaround::Routes;

sub startup {
    my $self = shift;

    $self->{home} = Turnaround::Home->new(path => 't');

    $self->SUPER::startup;
}

sub _build_routes {
    my $self = shift;

    my $routes = Turnaround::Routes->new;
    $routes->add_route('/:action');

    return $routes;
}

1;
