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

    my $app_scope = $self->app_scope;

    $app_scope->register_constant(app_class => ref $self);
    $app_scope->register(home => 'Lamework::Home', deps => 'app_class');

    $self->setup_app_scope;

    $self->startup;
}

sub app_scope {
    my $self = shift;

    $self->{app_scope} ||= Lamework::IOC->new;

    return $self->{app_scope};
}

sub setup_app_scope {
    my $self = shift;

    my $app_scope = $self->app_scope;

    $app_scope->register(routes => 'Lamework::Routes');
    $app_scope->register(
        dispatcher => 'Lamework::Dispatcher::Routes',
        deps       => 'routes'
    );

    $app_scope->register_constant(
        action_namespace => (ref $self) . '::Action::');
    $app_scope->register(
        action_scope_factory => 'Lamework::ActionScopeFactory');
    $app_scope->register(
        action_builder => 'Lamework::ActionBuilder',
        deps           => ['action_namespace', 'action_scope_factory'],
        aliases        => {action_namespace => 'namespace'}
    );

    $app_scope->register_constant(layout => 'layout');
    $app_scope->register(
        renderer => 'Lamework::Renderer::Caml',
        deps     => 'home'
    );
    $app_scope->register(
        displayer => 'Lamework::Displayer',
        deps      => ['home', 'renderer', 'layout']
    );
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
        enable '+Lamework::Middleware::MVC', app_scope => $self->app_scope;

        $self->default_app;
    };
}

sub default_app {
    sub { Lamework::HTTPException->throw(404) }
}

1;
