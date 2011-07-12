package Lamework;

use strict;
use warnings;

use base 'Lamework::Base';

use Plack::Builder;

use Lamework::Config;
use Lamework::Displayer;
use Lamework::Home;
use Lamework::HTTPException;
use Lamework::Registry;
use Lamework::Renderer::Caml;
use Lamework::Routes;

use overload q(&{}) => sub { shift->psgi_app }, fallback => 1;

sub new {
    my $self = shift->SUPER::new(@_);

    # Essential
    $self->registry->set_weaken(app => $self);
    $self->registry->set(home => Lamework::Home->new);

    $self->init;

    $self->startup;

    return $self;
}

sub registry { Lamework::Registry->instance }

sub init {
    my $self = shift;

    my $r = $self->registry;

    $r->set(config    => Lamework::Config->new);
    $r->set(displayer => Lamework::Displayer->new);
    $r->set(routes    => Lamework::Routes->new);

    return $self;
}

sub startup { $_[0] }

sub psgi_app {
    my $self = shift;

    return $self->{psgi_app} ||= $self->compile_psgi_app;
}

sub app {
    my $self = shift;

    sub {
        my $env = shift;

        my $message =
          Lamework::Registry->get('displayer')->render_file('not_found');
        Lamework::HTTPException->throw(404, message => $message);
      }
}

sub compile_psgi_app {
    my $self = shift;

    builder {
        enable 'Static' => path =>
          qr{\.(?:js|css|jpe?g|gif|ico|png|html?|swf|txt)$},
          root => Lamework::Registry->get('home')->catfile('htdocs');

        enable 'HTTPExceptions';

        enable 'SimpleLogger', level => $ENV{PLACK_ENV}
          && $ENV{PLACK_ENV} eq 'development' ? 'debug' : 'error';

        enable '+Lamework::Middleware::RoutesDispatcher';

        enable '+Lamework::Middleware::ActionBuilder';

        enable '+Lamework::Middleware::ViewDisplayer';

        enable 'ContentLength';

        $self->app;
    };
}

1;
