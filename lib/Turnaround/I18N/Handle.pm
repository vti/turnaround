package Turnaround::I18N::Handle;

use strict;
use warnings;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{language} = $params{language};
    $self->{handle}   = $params{handle};

    return $self;
}

sub language { $_[0]->{language} }

sub loc { &maketext }

sub maketext {
    my $self = shift;

    return $self->{handle}->maketext(@_);
}

1;
