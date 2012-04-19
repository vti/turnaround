package Turnaround::Displayer;

use strict;
use warnings;

use base 'Turnaround::Base';

sub BUILD {
    my $self = shift;

    die 'renderer required' unless $self->{renderer};
}

sub render {
    my $self = shift;
    my ($template) = shift;

    if (ref $template eq 'SCALAR') {
        return $self->_render_string($$template, @_);
    }

    return $self->_render_file($template, @_);
}

sub _render_file {
    my $self = shift;
    my ($template_file, %args) = @_;

    my $renderer = $self->{renderer};

    my $vars = $args{vars} || {};

    my $body = $renderer->render_file($template_file, $vars);

    if (defined(my $layout = $args{layout} || $self->{layout})) {
        $body =
          $renderer->render_file($layout, {%$vars, content => $body});
    }

    return $body;
}

sub _render_string {
    my $self = shift;
    my ($template_string, %args) = @_;

    my $renderer = $self->{renderer};

    my $vars = $args{vars} || {};

    return $renderer->render_string($template_string, $vars);
}

1;
