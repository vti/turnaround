package Turnaround::Routes::ConfigLoader;

use strict;
use warnings;

use base 'Turnaround::Config';

use Turnaround::Routes;

sub BUILD {
    my $self = shift;

    $self->SUPER::BUILD;

    $self->{routes} ||= Turnaround::Routes->new;
}

sub load {
    my $self = shift;

    my $routes = $self->{routes};

    my $config = $self->SUPER::load(@_);
    return $routes unless $config && ref $config eq 'ARRAY';

    foreach my $route (@{$config}) {
        $routes->add_route(delete $route->{route}, %$route);
    }

    return $routes;
}

1;
