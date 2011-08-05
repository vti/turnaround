package Lamework::Displayer;

use strict;
use warnings;

use base 'Lamework::Base';

sub render_file {
    my $self = shift;
    my ($file, %args) = @_;

    my $renderer = $self->{renderer};

    my $vars = $args{vars} || {};

    my $body = $renderer->render_file($file, $vars);

    if (defined(my $layout = $args{layout} || $self->{layout})) {
        $body =
          $renderer->render_file($layout, {%$vars, content => $body});
    }

    return $body;
}

sub render {
    my $self = shift;
    my ($template, %args) = @_;

    my $renderer = $self->{renderer};

    return $renderer->render($template, $args{vars});
}

1;
