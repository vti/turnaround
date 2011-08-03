package Lamework;

use strict;
use warnings;

use base 'Lamework::Base';

use Lamework::HTTPException;
use Lamework::Middleware::Core;

use Lamework::IOC;

use overload q(&{}) => sub { shift->psgi_app }, fallback => 1;

sub BUILD {
    my $self = shift;

    my $ioc = $self->ioc;

    $ioc->register(app => $self);
    $ioc->register(home => 'Lamework::Home', deps => 'app');

    $self->startup;
}

sub ioc {
    my $self = shift;

    $self->{ioc} ||= Lamework::IOC->new;

    return $self->{ioc};
}

sub startup { $_[0] }

sub psgi_app {
    my $self = shift;

    $self->{psgi_app} ||= Lamework::Middleware::Core->new(ioc => $self->ioc)
      ->wrap($self->build_psgi_app);

    return $self->{psgi_app};
}

sub build_psgi_app { $_[0]->app }

sub app {
    sub { Lamework::HTTPException->throw(404) }
}

1;
