package Turnaround::Renderer::Caml;

use strict;
use warnings;

use base 'Turnaround::Renderer';

use Text::Caml;

sub render_file {
    my $self = shift;
    my ($template, @rest) = @_;

    if ($template !~ m{\.[^\/\.]+$}) {
        $template .= '.caml';
    }

    return $self->{engine}->render_file($template, @rest);
}

sub render_string {
    my $self = shift;

    return $self->{engine}->render(@_);
}

sub _build_engine {
    my $self = shift;

    return Text::Caml->new(templates_path => $self->{templates_path}, @_);
}

1;
