package MyApp;

use strict;
use warnings;

use base 'Lamework';

use Plack::Builder;
use Lamework::Renderer::Caml;

sub startup {
    my $self = shift;

    $self->ioc->register(routes => 'Lamework::Routes');
    $self->ioc->register(displayer => 'Lamework::Displayer');

    $self->ioc->get_service('displayer', deps => 'home')
      ->add_format(
        caml => Lamework::Renderer::Caml->new(templates_path => 't/templates')
      );

    my $routes = $self->ioc->get_service('routes');

    $routes->add_route('/:action');
}

sub build_psgi_app {
    my $self = shift;

    builder {
        enable '+Lamework::Middleware::MVC', ioc => $self->ioc;

        $self->app;
    };
}

1;
