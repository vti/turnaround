package Turnaround::Config::Ini;

use strict;
use warnings;

use base 'Turnaround::Base';

use Config::Tiny;

sub parse {
    my $self = shift;
    my ($config) = @_;

    return Config::Tiny->read_string($config);
}

1;
