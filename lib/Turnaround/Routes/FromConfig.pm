package Turnaround::Routes::FromConfig;

use strict;
use warnings;

use base 'Turnaround::FromConfig';

use Turnaround::Routes;

sub BUILD {
    my $self = shift;

    $self->SUPER::BUILD;

    $self->{routes} ||= Turnaround::Routes->new;
}

sub _from_config {
    my $self = shift;
    my ($config) = @_;

    my $routes = $self->{routes};

    return $routes unless $config && ref $config eq 'ARRAY';

    foreach my $route (@{$config}) {
        $routes->add_route(delete $route->{route}, %$route);
    }

    return $routes;
}

1;
