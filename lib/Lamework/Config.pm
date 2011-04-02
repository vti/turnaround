package Lamework::Config;

use strict;
use warnings;

use Config::Tiny;

sub new {
    my $class = shift;

    my $self = {@_};
    bless $self, $class;

    return $self;
}

sub load {
    my $self = shift;
    my ($file) = @_;

    die "Can't open config file '$file'" unless -f $file;

    return Config::Tiny->read($file);
}

1;
