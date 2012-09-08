package Turnaround::Config::Pl;

use strict;
use warnings;

use base 'Turnaround::Base';

sub parse {
    my $self = shift;
    my ($config) = @_;

    return do $config;
}

1;
