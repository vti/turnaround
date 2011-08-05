package MyApp;

use strict;
use warnings;

use base 'Lamework';

use Lamework::Home;

sub startup {
    my $self = shift;

    $self->ioc->register(home => Lamework::Home->new(path => 't'));

    my $routes = $self->ioc->get_service('routes');

    $routes->add_route('/:action');
}

1;
