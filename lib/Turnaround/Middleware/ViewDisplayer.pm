package Turnaround::Middleware::ViewDisplayer;

use strict;
use warnings;

use base 'Turnaround::Middleware';

use Encode ();
use Plack::MIME;
use String::CamelCase ();

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{encoding} = $params{encoding} || 'UTF-8';
    $self->{displayer} =
         $params{displayer}
      || $self->{services}->service('displayer')
      || die 'displayer required';

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

    my %args;
    $args{vars}   = $env->{'turnaround.displayer.vars'};
    $args{layout} = $env->{'turnaround.displayer.layout'}
      if exists $env->{'turnaround.displayer.layout'};

    my $displayer = $self->{displayer};
    my $body = $displayer->render($template, %args);

    my $content_type = Plack::MIME->mime_type(".html");

    if (my $encoding = $self->{encoding}) {
        $body = Encode::encode($encoding, $body);
        $content_type .= '; charset=' . lc($encoding);
    }

    return [
        200,
        [
            'Content-Length' => length($body),
            'Content-Type'   => $content_type
        ],
        [$body]
    ];
}

sub _get_template {
    my $self = shift;
    my ($env) = @_;

    my $template = $env->{'turnaround.displayer.template'};
    return $template if $template;

    my $dispatched_request = $env->{'turnaround.dispatched_request'};
    return unless $dispatched_request;

    if (my $action = $dispatched_request->action) {
        my $template = String::CamelCase::decamelize($action);
        $template =~ s{::}{_}g;
        return $template;
    }

    return;
}

1;
