package Turnaround::ServiceContainer;

use strict;
use warnings;

use Carp qw(croak);
use Turnaround::Loader;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{services} = {};
    $self->{loader}   = $params{loader};

    $self->{loader} ||= Turnaround::Loader->new;

    return $self;
}

sub register {
    my $self = shift;
    my ($name, $value, %args) = @_;

    croak qq{service '$name' already registered}
      if exists $self->{services}->{$name};

    $self->{services}->{$name} = {value => $value, %args};

    return $self;
}

sub service {
    my $self = shift;
    my ($name, @args) = @_;

    croak qq{unknown service '$name'} unless exists $self->{services}->{$name};

    my $service = $self->{services}->{$name};

    my $instance;

    if (ref $service->{value} eq 'CODE') {
        $instance = $service->{value}->();
    }
    else {
        $instance = $service->{value};
    }

    return $instance;
}

1;
