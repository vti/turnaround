package Turnaround::ServiceContainer;

use strict;
use warnings;

require Carp;
use Scalar::Util ();
use Turnaround::Loader;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{services} = $params{services};
    $self->{loader}   = $params{loader};

    $self->{services} ||= {};

    $self->{loader} ||= Turnaround::Loader->new;

    return $self;
}

sub register {
    my $self = shift;
    my ($name, $value, %args) = @_;

    die qq{Service '$name' already registered}
      if exists $self->{services}->{$name};

    $self->{services}->{$name} = {value => $value, %args};

    return $self;
}

sub service {
    my $self = shift;
    my ($name, @args) = @_;

    die qq{Unknown service '$name'} unless exists $self->{services}->{$name};

    my $service = $self->{services}->{$name};

    return $service->{instance} if defined $service->{instance};

    my $instance;

    if (ref $service->{value} eq 'SCALAR') {
        $instance = ${$service->{value}};
    }
    elsif (ref $service->{value} eq 'CODE') {
        $instance = $service->{value}->();
    }
    elsif (!ref $service->{value}) {
        Carp::croak('value not set') unless $service->{value};

        $instance =
          $self->{loader}->load_class($service->{value})
          ->new($self->_resolve_arguments($service), @args);
    }
    else {
        $instance = $service->{value};
    }

    if (  !$service->{lifecycle}
        || $service->{lifecycle} ne 'prototype')
    {
        $self->{services}->{$name}->{instance} = $instance;
    }

    return $instance;
}

sub _resolve_arguments {
    my $self = shift;
    my ($service) = @_;

    return () unless my $services = $service->{services};

    my %arguments;

    my $count = 0;
    while (my ($name, $options) = @$services[$count, $count + 1]) {
        last unless $name;

        if (ref $options eq 'HASH') {
            my $key = $name;
            if (my $as = $options->{as}) {
                $key = $as;
            }

            my $value;
            if (defined(my $v = $options->{value})) {
                $value = $v;
            }
            else {
                $value = $self->service($name);
            }

            $arguments{$key} = $value;

            $count += 2;
        }
        else {
            $arguments{$name} = $self->service($name);

            $count++;
        }
    }

    return %arguments;
}

1;
