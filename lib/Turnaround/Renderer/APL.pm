package Turnaround::Renderer::APL;

use strict;
use warnings;

use base 'Turnaround::Renderer';

use Text::APL;
use File::Spec;

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
    $self->{engine}->render(
        name    => $template,
        input   => File::Spec->catfile($self->{templates_path}, $template),
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
    $self->{engine}->render(input => \$template, output => \$output, @rest);

    return $output;
}

sub _build_engine {
    my $self = shift;

    return Text::APL->new(cache => 1, @_);
}

1;
