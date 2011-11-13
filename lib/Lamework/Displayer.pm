package Lamework::Displayer;

use strict;
use warnings;

use base 'Lamework::Base';

sub BUILD {
    my $self = shift;

    die 'renderer required' unless $self->{renderer};
}

sub render_file {
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

sub render {
    my $self = shift;
    my ($template_string, %args) = @_;

    my $renderer = $self->{renderer};

    my $vars = $args{vars} || {};

    return $renderer->render($template_string, $vars);
}

1;
