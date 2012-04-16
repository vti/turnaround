package Turnaround::Middleware::ViewDisplayer;

use strict;
use warnings;

use base 'Turnaround::Middleware';

use Encode ();
use Plack::MIME;
use String::CamelCase ();

sub new {
    my $self = shift->SUPER::new(@_);

    $self->{encoding} ||= 'UTF-8';

    return $self;
}

sub call {
    my $self = shift;
    my ($env) = @_;

    my $res = $self->_display($env);
    return $res if $res;

    return $self->app->($env);
}

sub _display {
    my $self = shift;
    my ($env) = @_;

    my $template = $self->_get_template($env);
    return unless defined $template;

    my $vars   = $env->{'lamework.displayer.vars'};
    my $layout = $env->{'lamework.displayer.layout'};

    my $body =
      $self->{displayer}
      ->render_file($template, vars => $vars, layout => $layout);

    my $content_type = Plack::MIME->mime_type(".html");

    if (my $encoding = $self->{encoding}) {
        $body = Encode::encode($encoding, $body);
        $content_type .= '; charset=' . lc($encoding);
    }

    return [
        200,
        [   'Content-Length' => length($body),
            'Content-Type'   => $content_type
        ],
        [$body]
    ];
}

sub _get_template {
    my $self = shift;
    my ($env) = @_;

    my $template = $env->{'lamework.displayer.template'};
    return $template if $template;

    my $dispatched_request = $env->{'lamework.dispatched_request'};
    return unless $dispatched_request;

    if (my $action = $dispatched_request->get_action) {
        my $template = String::CamelCase::decamelize($action);
        $template =~ s{::}{_}g;
        return $template;
    }

    return;
}

1;
