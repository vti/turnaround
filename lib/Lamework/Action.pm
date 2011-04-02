package Lamework::Action;

use strict;
use warnings;

use Scalar::Util qw(weaken);

use Lamework::Logger;
use Lamework::Registry;
use Lamework::Request;
use Lamework::Response;

sub new {
    my $class = shift;

    my $self = {@_};
    bless $self, $class;

    weaken $self->{env};

    return $self;
}

sub log {
    my $self = shift;

    $self->{logger}
      ||= Lamework::Logger->new(logger => $self->{env}->{'psgix.logger'});

    return $self->{logger};
}

sub captures {
    my $self = shift;

    return $self->{env}->{'lamework.routes.match'}->params;
}

sub env {
    my $self = shift;

    return $self->{env};
}

sub req {
    my $self = shift;

    $self->{req} ||= Lamework::Request->new($self->{env});

    return $self->{req};
}

sub res {
    my $self = shift;

    $self->{res} ||= $self->req->new_response;

    return $self->{res};
}

sub url_for {
    my $self = shift;

    my $url;

    if ($_[0] =~ m{^/}) {
        my $path = $_[0];
        $path =~ s{^/}{};

        $url = $self->req->base;
        $url->path($url->path . $path);
    }
    elsif ($_[0] =~ m{^https?://}) {
        $url = $_[0];
    }
    else {
        my $routes = Lamework::Registry->get('routes');

        my $path = $routes->build_path(@_);
        $path =~ s{^/}{};

        $url = $self->req->base;
        $url->path($url->path . $path);
    }

    return $url;
}

sub set_var {
    my $self = shift;
    my ($key, $value) = @_;

    $self->{env}->{'lamework.displayer.vars'}->{$key} = $value;
}

sub set_template {
    my $self = shift;
    my ($template) = @_;

    $self->{env}->{'lamework.displayer.template'} = $template;
}

sub redirect {
    my $self = shift;
    my (@args) = @_;

    my $url = $self->url_for(@_);
    $self->res->redirect($url);

    return $self;
}

sub render_file {
    my $self = shift;

    my $displayer = Lamework::Registry->get('displayer');

    my $body = $displayer->render_file(@_);

    unless (defined $self->res->code) {
        $self->res->code(200);
    }

    $self->res->body($body);

    return $self;
}

sub render_forbidden {
    my $self = shift;

    $self->res->code(403);
    $self->render_file('forbidden', @_);

    return $self;
}

sub render_not_found {
    my $self = shift;

    $self->res->code(404);
    $self->render_file('not_found', @_);

    return $self;
}

1;
