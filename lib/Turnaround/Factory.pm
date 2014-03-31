package Turnaround::Factory;

use strict;
use warnings;

use String::CamelCase ();

use Turnaround::Loader;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{try} = $params{try};

    $self->{namespaces} = $params{namespaces};
    $self->{namespaces} = [] unless defined $self->{namespaces};
    $self->{namespaces} = [$self->{namespaces}]
      unless ref $self->{namespaces} eq 'ARRAY';

    return $self;
}

sub build {
    my $self = shift;
    my ($name, @args) = @_;

    my $class = $self->_build_class_name($name);

    my $loaded_class = $self->_load_class($class);
    return unless $loaded_class;

    return $self->_build_object($loaded_class, @args);
}

sub _build_class_name {
    my $self = shift;
    my ($action) = @_;

    $action =~ s{-}{::}g;

    return String::CamelCase::camelize($action);
}

sub _load_class {
    my $self = shift;
    my ($class) = @_;

    my $loader = Turnaround::Loader->new(namespaces => $self->{namespaces});

    return $loader->try_load_class($class) if $self->{try};

    $loader->load_class($class);
}

sub _build_object {
    my $self = shift;
    my ($class, @args) = @_;

    return $class->new(@args);
}

1;
