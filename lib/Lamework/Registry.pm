package Lamework::Registry;

use strict;
use warnings;

use Scalar::Util qw(weaken);

sub instance {
    my $class = shift;

    no strict;

    ${"$class\::_instance"} ||= $class->_new_instance(@_);

    return ${"$class\::_instance"};
}

sub set {
    my $class = shift;
    my ($key, $value, %args) = @_;

    $class->instance->{objects}->{$key} = $value;

    return $class;
}

sub set_weaken {
    my $class = shift;
    my ($key, $value) = @_;

    $class->instance->{objects}->{$key} = $value;
    weaken $class->instance->{objects}->{$key};

    return $class;
}

sub get {
    my $class = shift;
    my ($key) = @_;

    return $class->instance->{objects}->{$key};
}

sub _new_instance {
    my $class = shift;

    my $self = bless {@_}, $class;

    $self->{objects} = {};

    return $self;
}

1;
