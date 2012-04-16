package Turnaround::Config::Yml;

use strict;
use warnings;

use base 'Turnaround::Base';

use YAML::Tiny;

sub parse {
    my $self = shift;
    my ($config) = @_;

    $config = YAML::Tiny->read_string($config) or die $YAML::Tiny::errstr;
    return $config->[0];
}

1;
