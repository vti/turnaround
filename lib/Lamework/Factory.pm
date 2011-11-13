package Lamework::Factory;

use strict;
use warnings;

use base 'Lamework::Base';

use Class::Load       ();
use String::CamelCase ();
use Try::Tiny;

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

    return try {
        Class::Load::load_class($class);

        return $self->_build_object($class, %{$self->{default_args}}, @args);
    }
    catch {
        $class =~ s{::}{/}g;

        die $_ unless $_ =~ m{^Can't locate $class\.pm in \@INC };

        Lamework::Exception->throw(class => 'Factory', message => $_);
    };
}

sub _build_class_name {
    my $self = shift;
    my ($action) = @_;

    $action = String::CamelCase::camelize($action);

    return "$self->{namespace}$action";
}

sub _build_object {
    my $self = shift;
    my ($class, @args) = @_;

    return $class->new(@args);
}

1;
