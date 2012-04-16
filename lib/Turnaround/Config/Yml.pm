package Turnaround::Config::Yml;

use strict;
use warnings;

use base 'Turnaround::Base';

use YAML::Tiny;

sub parse {
    my $self = shift;
    my ($config) = @_;

    YAML::Tiny->read_string($config)->[0];
}

1;
