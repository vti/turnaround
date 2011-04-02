package Lamework::Renderer::Caml;

use strict;
use warnings;

use base 'Lamework::Renderer';

use Text::Caml;

sub new {
    my $self = shift->SUPER::new;

    $self->{caml} = Text::Caml->new(@_);

    return $self;
}

sub render_file {
    my $self = shift;

    return $self->{caml}->render_file(@_);
}

sub render {
    my $self = shift;

    return $self->{caml}->render(@_);
}

1;
