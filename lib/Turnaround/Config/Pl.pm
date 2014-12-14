package Turnaround::Config::Pl;

use strict;
use warnings;

use Carp qw(croak);

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub parse {
    my $self = shift;
    my ($config) = @_;

    return eval $config or croak $@;
}

1;
