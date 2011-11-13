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

    #weaken $self->{env};

    return $self;
}

sub get {
    my $self = shift;
    my ($name) = @_;

    return $self->to_hash->{"lamework.$name"};
}

sub set {
    my $self = shift;
    my ($name, $value) = @_;

    $self->to_hash->{"lamework.$name"} = $value;

    return $self;
}

sub to_hash {
    my $self = shift;

    return $self->[0]->{env};
}

1;
