package Lamework::IOC;

use strict;
use warnings;

use base 'Lamework::Base';

require Carp;

use Class::Load  ();
use Scalar::Util ();

sub register {
    my $self = shift;
    my $key  = shift;

    Carp::croak('Service name is required') unless $key;

    if (@_ == 1 && !(ref($_[0]) eq 'HASH')) {
        my $type =
            Scalar::Util::blessed($_[0]) ? 'instance'
          : ref($_[0]) eq 'CODE' ? 'block'
          :                        'constant';
        $self->{services}->{$key}->{$type} = $_[0];
        return $self;
    }

    $self->{services}->{$key} = @_ == 1 ? $_[0] : {@_};

    return $self;
}

sub get {
    my $self = shift;
    my ($key) = @_;

    my $service = $self->_get($key);

    if (exists $service->{instance}) {
        return $service->{instance};
    }
    elsif (exists $service->{block}) {
        my %args = $self->_build_deps($service);
        return $service->{block}->($self, %args);
    }

    if ($service->{lifecycle} && $service->{lifecycle} eq 'prototype') {
        return $self->_build_service($service);
    }

    return $service->{instance} = $self->_build_service($service);
}

sub get_all {
    my $self = shift;

    my @services;
    foreach my $service (keys %{$self->{services}}) {
        push @services, $service => $self->get($service);
    }

    return @services;
}

sub _get {
    my $self = shift;
    my ($key) = @_;

    die "Service '$key' does not exist"
      unless exists $self->{services}->{$key};

    return $self->{services}->{$key};
}

sub _build_service {
    my $self = shift;
    my ($service) = @_;

    return $service->{constant} if exists $service->{constant};

    Class::Load::load_class($service->{class});

    my %args = $self->_build_deps($service);

    return $service->{class}->new(%args);
}

sub _build_deps {
    my $self = shift;
    my ($service) = @_;

    if (my $deps = $service->{deps}) {
        $deps = [$deps] unless ref $deps eq 'ARRAY';

        my %args;
        foreach my $dep (@$deps) {
            my ($key, $value) = ($dep, $dep);

            if (ref $dep eq 'HASH') {
                $key   = (keys(%$dep))[0];
                $value = (values(%$dep))[0];
            }

            $args{$key} = $self->get($value);
        }

        return %args;
    }

    return ();
}

1;
