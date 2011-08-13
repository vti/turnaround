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

    my $scope = $self->scope;

    $scope->register(app_class => ref $self);
    $scope->register(home => class => 'Lamework::Home', deps => 'app_class');

    $self->setup_scope;

    $self->startup;
}

sub scope {
    my $self = shift;

    $self->{scope} ||= Lamework::IOC->new;

    return $self->{scope};
}

sub setup_scope {
    my $self = shift;

    my $scope = $self->scope;

    $scope->register('routes', class => 'Lamework::Routes');
    $scope->register(
        'dispatcher',
        class => 'Lamework::Dispatcher::Routes',
        deps  => 'routes'
    );

    $scope->register(action_namespace => (ref $self) . '::Action::');
    $scope->register(
        'action_builder',
        class => 'Lamework::ActionBuilder',
        deps  => {namespace => 'action_namespace'}
    );

    $scope->register(layout => 'layout');
    $scope->register(
        'renderer',
        class => 'Lamework::Renderer::Caml',
        deps  => 'home'
    );
    $scope->register(
        'displayer',
        class => 'Lamework::Displayer',
        deps  => ['home', 'renderer', 'layout']
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
        enable '+Lamework::Middleware::MVC', scope => $self->scope;

        $self->default_app;
    };
}

sub default_app {
    sub { Lamework::HTTPException->throw(404) }
}

1;
