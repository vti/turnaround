package MyApp;

use strict;
use warnings;

use base 'Lamework';

sub startup {
    my $self = shift;

    my $routes = $self->registry->get('routes');

    $routes->add_route('/:action');
}

1;
