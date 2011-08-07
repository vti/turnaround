package MyApp;

use strict;
use warnings;

use base 'Lamework';

use Lamework::Home;

sub startup {
    my $self = shift;

    $self->app_scope->register(home => Lamework::Home->new(path => 't'));
    $self->app_scope->register_constant(layout => undef);

    my $routes = $self->app_scope->get_service('routes');

    $routes->add_route('/:action');
}

1;
