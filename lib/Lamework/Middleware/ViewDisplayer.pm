package Lamework::Middleware::ViewDisplayer;

use strict;
use warnings;

use base 'Lamework::Middleware';

use Encode ();
use Plack::MIME;
use String::CamelCase ();

use Lamework::Env;
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

    $env = Lamework::Env->new($env);

    my $template = $self->_get_template($env);
    return unless defined $template;

    my $displayer = Lamework::Registry->get('displayer');

    my @args = (
        template => $env->template,
        layout   => $env->layout,
        vars     => $env->vars,
    );

    my $body = $displayer->render_file($template, @args);

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

sub _get_template {
    my $self = shift;
    my ($env) = @_;

    my $template = $env->template;

    if (!$template) {
        my $env =  Lamework::Env->new($env);

        if (defined(my $action = $env->captures->{action})) {
            $template = $self->_action_to_template($action);
        }
        elsif (my $match = $env->match) {
            return unless defined $match->name;
            $template = $match->name;
        }
    }

    return $template;
}

sub _action_to_template {
    my $self = shift;
    my ($action) = @_;

    $action =~ s{::}{/}g;

    return String::CamelCase::decamelize($action);
}

1;
