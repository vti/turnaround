package Lamework::Config;

use strict;
use warnings;

use base 'Lamework::Base';

use overload '{}' => sub { $_[0]->config }, fallback => 1;

sub BUILD {
    my $self = shift;

    $self->{loader} ||= do {
        require Lamework::Config::Ini;
        Lamework::Config::Ini->new;
    };

    return $self;
}

sub config {
    my $self = shift;

    $self->{config} ||= $self->{loader}->load;

    return $self->{config};
}

sub load {
    my $self = shift;

    return $self->{loader}->load(@_);
}

1;
