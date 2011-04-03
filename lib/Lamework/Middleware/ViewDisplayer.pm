package Lamework::Middleware::ViewDisplayer;

use strict;
use warnings;

use base 'Lamework::Middleware';

use Encode ();
use Plack::MIME;
use String::CamelCase ();

use Lamework::Registry;

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

    my $template = $self->_template($env);
    return unless defined $template;

    my $displayer = Lamework::Registry->get('displayer');
    my $vars = $env->{'lamework.displayer.vars'} || {};

    my $body = $displayer->render_file($template, vars => $vars);

    my $content_type = Plack::MIME->mime_type(".html");

    if (Encode::is_utf8($body)) {
        $body = Encode::encode('UTF-8', $body);
        $content_type .= '; charset=utf-8';
    }

    return [
        200,
        [   'Content-Length' => length($body),
            'Content-Type'   => $content_type
        ],
        [$body]
    ];
}

sub _template {
    my $self = shift;
    my ($env) = @_;

    my $template = $env->{'lamework.displayer.template'};

    if (!$template) {
        my $match = $env->{'lamework.routes.match'};
        return unless $match;

        my $action = $match->params->{action};
        $template =
          $action ? $self->_action_to_template($action) : $match->name;
    }

    return $template;
}

sub _action_to_template {
    my $self = shift;
    my ($action) = @_;

    return String::CamelCase::decamelize($action);
}

1;
