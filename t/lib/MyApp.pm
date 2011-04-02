package MyApp;

use strict;
use warnings;

use base 'Lamework';

sub startup {
    my $self = shift;

    my $routes = $self->routes;

    $routes->add_route('/auto', name => 'auto_rendering');
    $routes->add_route('/custom_response',
        defaults => {action => 'custom_response'});
    $routes->add_route('/no_action', name => 'no_action');
}

1;
