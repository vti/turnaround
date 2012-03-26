package Lamework::Env;

use strict;
use warnings;

use Scalar::Util qw(weaken);

use overload
  '%{}'    => sub { $_[0]->to_hash },
  'bool'   => sub { $_[0]->to_hash },
  '""'     => sub { $_[0]->to_hash },
  fallback => 1;

sub new {
    my $class = shift;
    my ($env) = @_;

    die 'env is required' unless $env;

    my $self = [{env => $env}];
    bless $self, $class;

    return $self;
}

sub get {
    my $self = shift;
    my ($name) = @_;

    $name = $self->_build_name($name);

    my @parts = split /\./ => $name;

    my $head = $self->to_hash;
    for my $part (@parts) {
        return unless exists $head->{$part};
        $head = $head->{$part};
    }

    return $head;
}

sub set {
    my $self = shift;
    my (%params) = @_;

    while (my ($name, $value) = each %params) {
        $name = $self->_build_name($name);

        my @parts = split /\./ => $name;
        $name = pop @parts;

        my $head = $self->to_hash;
        for my $part (@parts) {
            $head->{$part} = {} unless exists $head->{$part};
            $head = $head->{$part};
        }

        $head->{$name} = $value;
    }

    return $self;
}

sub to_hash {
    my $self = shift;

    return $self->[0]->{env};
}

sub _build_name {
    my $self = shift;
    my ($name) = @_;

    return "lamework.$name";
}

1;
