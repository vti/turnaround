package Lamework;

use strict;
use warnings;

use base 'Lamework::Base';

our $VERSION = '0.1';

use Lamework::Middleware::HTTPExceptions;

use Lamework::Home;
use Lamework::HTTPException;
use Lamework::Registry;

use overload q(&{}) => sub { shift->to_app }, fallback => 1;

sub BUILD {
    my $self = shift;

    my $registry = $self->registry;
    $registry->set(home => Lamework::Home->new(app_class => ref $self));

    $self->startup;
}

sub startup { $_[0] }

sub registry {
    my $self = shift;

    $self->{registry} ||= Lamework::Registry->instance($self);

    return $self->{registry};
}

sub to_app {
    my $self = shift;

    if (!$self->{psgi_app}) {
        $self->{psgi_app} =
          Lamework::Middleware::HTTPExceptions->new(
            displayer => $self->registry->get('displayer'))->wrap($self->app);
    }

    return $self->{psgi_app};
}

sub app {
    my $self = shift;

    $self->default_app;
}

sub default_app {
    sub { Lamework::HTTPException->throw(404) }
}

1;
