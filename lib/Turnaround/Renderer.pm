package Turnaround::Renderer;

use strict;
use warnings;

use File::Spec ();

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{home}           = $params{home};
    $self->{templates_path} = $params{templates_path};
    $self->{engine_args}    = $params{engine_args};

    my $templates_path = delete $self->{templates_path} || 'templates';
    if (!File::Spec->file_name_is_absolute($templates_path) && $self->{home}) {
        $templates_path = File::Spec->catfile($self->{home}, $templates_path);
    }
    $self->{templates_path} = $templates_path;

    $self->{engine} = $self->_build_engine(%{$self->{engine_args} || {}});

    return $self;
}

sub render_file { ... }

sub render_string { ... }

sub _build_engine { ... }

1;
