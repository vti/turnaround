package MyApp;

use strict;
use warnings;

use base 'Lamework::SimpleApp';

use Lamework::Home;
use Lamework::Routes;

sub startup {
    my $self = shift;

    $self->{home} = Lamework::Home->new(path => 't');

    $self->SUPER::startup;
}

sub _build_routes {
    my $self = shift;

    my $routes = Lamework::Routes->new;
    $routes->add_route('/:action');

    return $routes;
}

1;
