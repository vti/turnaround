package Lamework::Renderer;

use strict;
use warnings;

sub new {
    my $class = shift;

    my $self = {@_};
    bless $self, $class;

    return $self;
}

sub render_file { }

sub render { }

1;
