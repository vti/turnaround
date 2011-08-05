package Lamework;

use strict;
use warnings;

use base 'Lamework::Base';

use Plack::Builder;

use Lamework::HTTPException;
use Lamework::Middleware::Core;

use Lamework::IOC;

use overload q(&{}) => sub { shift->to_app }, fallback => 1;

sub BUILD {
    my $self = shift;

    my $ioc = $self->ioc;

    $ioc->register(app => $self);
    $ioc->register(home => 'Lamework::Home', deps => 'app');

    $self->startup;
}

sub ioc {
    my $self = shift;

    $self->{ioc} ||= do {
        my $ioc = Lamework::IOC->new;

        $ioc->register(routes => 'Lamework::Routes');
        $ioc->register(
            dispatcher => 'Lamework::Dispatcher::Routes',
            deps       => 'routes'
        );

        $ioc->register(
            renderer => 'Lamework::Renderer::Caml',
            deps     => ['home']
        );
        $ioc->register(
            displayer => 'Lamework::Displayer',
            deps      => ['home', 'renderer']
        );

        $ioc;
    };

    return $self->{ioc};
}

sub startup { $_[0] }

sub to_app {
    my $self = shift;

    $self->{psgi_app} ||= Lamework::Middleware::Core->new(ioc => $self->ioc)
      ->wrap($self->app);

    return $self->{psgi_app};
}

sub app {
    my $self = shift;

    builder {
        enable '+Lamework::Middleware::MVC', ioc => $self->ioc;

        $self->default_app;
    };
}

sub default_app {
    sub { Lamework::HTTPException->throw(404) }
}

1;
