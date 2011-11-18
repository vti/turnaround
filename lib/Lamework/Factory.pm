package Lamework::Factory;

use strict;
use warnings;

use base 'Lamework::Base';

use Class::Load       ();
use String::CamelCase ();
use Try::Tiny;

use Lamework::Loader;
use Lamework::Exception;

sub BUILD {
    my $self = shift;

    $self->{namespace} = '' unless defined $self->{namespace};

    $self->{default_args} ||= {};
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

    my $loader = Lamework::Loader->new;

    $loader->load_class($class);
}

sub _build_object {
    my $self = shift;
    my ($class, @args) = @_;

    return $class->new(@args);
}

1;
