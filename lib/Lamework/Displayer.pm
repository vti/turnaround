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
        $file .= '.' . $self->_default_format;
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

    my $format   = $args{format};
    my $renderer = $self->_renderer($format);

    return $renderer->render($template, $args{vars});
}

sub _default_format {
    my $self = shift;

    my $format = $self->{default_format};
    return $format if $format;

    if (keys(%{$self->{formats}}) == 1) {
        ($format) = keys %{$self->{formats}};
    }
    else {
        die 'No default format defined';
    }

    return $format;
}

sub _renderer {
    my $self = shift;
    my ($format) = @_;

    $format ||= $self->_default_format;

    die "Format is required '$format'" unless defined $format;

    return $self->{formats}->{$format};
}

1;
