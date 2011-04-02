package Lamework::Displayer;

use strict;
use warnings;

sub new {
    my $class = shift;

    my $self = {@_};
    bless $self, $class;

    return $self;
}

sub render_file {
    my $self = shift;
    my ($file, %args) = @_;

    my ($format) = ($file =~ m{\.([^\.]+)$});

    if (!$format) {
        $file .= '.' . $self->{default_format};
    }

    my $renderer = $self->_renderer($format);

    my $body = $renderer->render_file($file, $args{vars} || {});

    if (defined(my $layout = delete $args{layout})) {
        $body = $renderer->render_file($layout, {content => $body});
    }

    return $body;
}

sub render {
    my $self = shift;
    my ($template, %args) = @_;

    my $format = $args{format};
    my $renderer = $self->_renderer($format);

    return $renderer->render($template, $args{vars});
}

sub _renderer {
    my $self = shift;
    my ($format) = @_;

    $format ||= $self->{default_format};

    return $self->{formats}->{$format};
}

1;
