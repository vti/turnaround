package Turnaround::Renderer::Caml;

use strict;
use warnings;

use base 'Turnaround::Renderer';

use Text::Caml;
use File::Spec ();

sub BUILD {
    my $self = shift;

    my $templates_path = delete $self->{templates_path} || 'templates';
    if (!File::Spec->file_name_is_absolute($templates_path) && $self->{home}) {
        $templates_path = $self->{home}->catfile($templates_path);
    }

    $self->{caml} = Text::Caml->new(templates_path => $templates_path, @_);

    return $self;
}

sub render_file {
    my $self = shift;
    my ($template, @rest) = @_;

    if ($template !~ m{\.[^\/\.]+$}) {
        $template .= '.caml';
    }

    return $self->{caml}->render_file($template, @rest);
}

sub render_string {
    my $self = shift;

    return $self->{caml}->render(@_);
}

1;
