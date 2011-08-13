package MyApp;

use strict;
use warnings;

use base 'Lamework';

use Lamework::Home;

sub startup {
    my $self = shift;

    $self->scope->register(home => Lamework::Home->new(path => 't'));
    $self->scope->register(layout => undef);

    my $routes = $self->scope->get('routes');

    $routes->add_route('/:action');
}

1;
