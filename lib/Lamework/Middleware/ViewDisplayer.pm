package Lamework::Middleware::ViewDisplayer;

use strict;
use warnings;

use base 'Lamework::Middleware';

use Encode ();
use Plack::MIME;
use String::CamelCase ();

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

    my $args = $env->{'lamework.displayer'} || {};

    my $displayer = $self->{displayer};

    my $body = $displayer->render_file($template, %$args);

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

    my $template = $env->{'lamework.displayer'}->{template};
    return $template if $template;

    my $dispatched_request = $env->{'lamework.dispatched_request'};
    return unless $dispatched_request;

    if (my $action = $dispatched_request->captures->{action}) {
        my $template = String::CamelCase::decamelize($action);
        $template =~ s{::}{_}g;
        return $template;
    }

    return;
}

1;
