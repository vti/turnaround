package Lamework::Action;

use strict;
use warnings;

use Plack::App::File;

use Scalar::Util qw(weaken);
use Encode ();

use Lamework::HTTPException;
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

sub run {
    my $self = shift;

    if ($self->{cb}) {
        return $self->{cb}->($self);
    }

    die "Method 'run' in action '" . ref($self) . "' must be overwritten";
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

    for (my $i = 0; $i < @_; $i += 2) {
        my $key   = $_[$i];
        my $value = $_[$i + 1];

        $self->{env}->{'lamework.displayer'}->{'vars'}->{$key} = $value;
    }

    return $self;
}

sub vars {
    my $self = shift;

    return $self->{env}->{'lamework.displayer'}->{'vars'};
}

sub set_template {
    my $self = shift;
    my ($template) = @_;

    $self->{env}->{'lamework.displayer.template'} = $template;
}

sub set_layout {
    my $self = shift;
    my ($layout) = @_;

    $self->{env}->{'lamework.displayer.layout'} = $layout;
}

sub render_file {
    my $self = shift;
    my $file = shift;

    my $displayer = Lamework::Registry->get('displayer');

    my $args = $self->env->{'lamework.displayer'};

    my $body = $displayer->render_file($file, %$args, @_);

    unless (defined $self->res->code) {
        $self->res->code(200);
    }

    if (Encode::is_utf8($body)) {
        $body = Encode::encode('UTF-8', $body);
    }

    $self->res->body($body);

    return $self;
}

sub forbidden {
    my $self = shift;
    my ($message) = @_;

    $message
      ||= Lamework::Registry->get('displayer')->render_file('forbidden');

    Lamework::HTTPException->throw(403, message => $message);
}

sub not_found {
    my $self = shift;
    my ($message) = @_;

    $message
      ||= Lamework::Registry->get('displayer')->render_file('not_found');

    Lamework::HTTPException->throw(404, message => $message)
}

sub redirect {
    my $self = shift;

    my $url = $self->url_for(@_);

    Lamework::HTTPException->throw(302, location => $url);
}

sub serve_file {
    my $self = shift;
    my ($path) = @_;

    return $self->not_found unless -e $path;

    return $self->forbidden unless -r $path;

    my $app = Plack::App::File->new(file => $path);

    my $res = $app->serve_path($self->env, $path);

    $self->res->code($res->[0]);
    $self->res->headers($res->[1]);
    $self->res->body($res->[2]);

    return $self;
}

1;
