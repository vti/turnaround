package Lamework;

use strict;
use warnings;

use base 'Lamework::Base';

our $VERSION = '0.1';

use Plack::Builder;
use Plack::Middleware::HTTPExceptions;

use Lamework::HTTPException;
use Lamework::IOC;

use overload q(&{}) => sub { shift->to_app }, fallback => 1;

sub BUILD {
    my $self = shift;

    my $ioc = $self->ioc;

    $ioc->register_constant(app_class => ref $self);
    $ioc->register(home => 'Lamework::Home', deps => 'app_class');

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

        $ioc->register_constant(
            action_namespace => (ref $self) . '::Action::');
        $ioc->register(
            action_builder => 'Lamework::ActionBuilder',
            deps           => 'action_namespace',
            aliases        => {action_namespace => 'namespace'}
        );

        $ioc->register_constant(layout => 'layout');
        $ioc->register(
            renderer => 'Lamework::Renderer::Caml',
            deps     => 'home'
        );
        $ioc->register(
            displayer => 'Lamework::Displayer',
            deps      => ['home', 'renderer', 'layout']
        );

        $ioc;
    };

    return $self->{ioc};
}

sub startup { $_[0] }

sub to_app {
    my $self = shift;

    $self->{psgi_app}
      ||= Plack::Middleware::HTTPExceptions->new->wrap($self->app);

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
