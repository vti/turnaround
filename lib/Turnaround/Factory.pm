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

    $self->{namespace} = $params{namespace};
    $self->{namespace} = '' unless defined $self->{namespace};

    $self->{default_args} = $params{default_args} || {};

    return $self;
}

sub build {
    my $self = shift;
    my ($name, @args) = @_;

    my $class = $self->_build_class_name($name);

    $self->_load_class($class);

    return $self->_build_object($class, %{$self->{default_args}}, @args);
}

sub _build_class_name {
    my $self = shift;
    my ($action) = @_;

    $action = String::CamelCase::camelize($action);

    return "$self->{namespace}$action";
}

sub _load_class {
    my $self = shift;
    my ($class) = @_;

    my $loader = Turnaround::Loader->new;

    $loader->load_class($class);
}

sub _build_object {
    my $self = shift;
    my ($class, @args) = @_;

    return $class->new(@args);
}

1;
