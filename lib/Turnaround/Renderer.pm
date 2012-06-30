package Turnaround::Renderer;

use strict;
use warnings;

use base 'Turnaround::Base';

use File::Spec ();

sub BUILD {
    my $self = shift;

    my $templates_path = delete $self->{templates_path} || 'templates';
    if (!File::Spec->file_name_is_absolute($templates_path) && $self->{home}) {
        $templates_path = $self->{home}->catfile($templates_path);
    }
    $self->{templates_path} = $templates_path;

    $self->{engine} = $self->_build_engine(%{$self->{engine_args} || {}});

    return $self;
}

sub render_file { }

sub render_string { }

1;
