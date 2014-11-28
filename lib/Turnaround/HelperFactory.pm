package Turnaround::HelperFactory;

use strict;
use warnings;

use base 'Turnaround::Factory';

require Carp;
use Scalar::Util ();

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{env} = $params{env};
    Scalar::Util::weaken($self->{env});

    $self->{req} = $params{req};
    Scalar::Util::weaken($self->{req});

    return $self;
}

sub register_helper {
    my $self = shift;
    my ($name, $object) = @_;

    Carp::croak("Helper '$name' already registered")
      if exists $self->{helpers}->{$name};

    $self->{helpers}->{$name} = $object;
}

sub build {
    my $self = shift;
    my ($name, @args) = @_;

    return $self->SUPER::build(
        $name,
        env => $self->{env},
        req => $self->{req},
        @args
    );
}

sub create_helper {
    my $self = shift;
    my ($name) = @_;

    if (exists $self->{helpers}->{$name}) {
        my $helper = $self->{helpers}->{$name};

        return
            ref $helper eq 'CODE' ? $helper->()
          : Scalar::Util::blessed($helper) ? $helper
          :                                  $self->build($helper);
    }

    return $self->build($name);
}

sub DESTROY { }

our $AUTOLOAD;
sub AUTOLOAD {
    my $self = shift;

    my ($method) = (split /::/, $AUTOLOAD)[-1];

    return if $method =~ /[A-Z]/;

    return $self->create_helper($method, @_);
}

1;
