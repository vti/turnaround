package Turnaround::Renderer::APL;

use strict;
use warnings;

use base 'Turnaround::Renderer';

use Text::APL;
use File::Spec ();

sub BUILD {
    my $self = shift;

    my $templates_path = delete $self->{templates_path} || 'templates';
    if (!File::Spec->file_name_is_absolute($templates_path) && $self->{home}) {
        $templates_path = $self->{home}->catfile($templates_path);
    }

    $self->{templates_path} = $templates_path;

    $self->{apl} = Text::APL->new;

    return $self;
}

sub render_file {
    my $self = shift;
    my ($template, @rest) = @_;

    if ($template !~ m{\.[^\/\.]+$}) {
        $template .= '.apl';
    }

    my %helpers =
      map { $_ => $rest[0]->{$_} }
      grep { ref $rest[0]->{$_} eq 'CODE' } keys %{$rest[0]};
    my %vars =
      map { $_ => $rest[0]->{$_} }
      grep { ref $rest[0]->{$_} ne 'CODE' } keys %{$rest[0]};

    my $output = '';
    $self->{apl}->render(
        input   => $self->{templates_path}->catfile($template)->to_string,
        output  => \$output,
        vars    => \%vars,
        helpers => \%helpers
    );

    return $output;
}

sub render_string {
    my $self = shift;
    my ($template, @rest) = @_;

    my $output = '';
    $self->{apl}->render(input => \$template, output => \$output, @rest);

    return $output;
}

1;
