package Lamework::ActionBuilder;

use strict;
use warnings;

use base 'Lamework::Base';

use Class::Load       ();
use String::CamelCase ();
use Try::Tiny;

sub BUILD {
    my $self = shift;

    $self->{namespace} = '' unless defined $self->{namespace};

    $self->{default_args} ||= {};
}

sub build {
    my $self = shift;
    my ($action, @args) = @_;

    my $class = $self->_build_class_name($action);

    return try {
        Class::Load::load_class($class);

        return $self->_build_action($class, %{$self->{default_args}}, @args);
    }
    catch {
        $class =~ s{::}{/}g;

        die $_ unless $_ =~ m{^Can't locate $class\.pm in \@INC };

        return;
    };
}

sub _build_class_name {
    my $self = shift;
    my ($action) = @_;

    $action = String::CamelCase::camelize($action);

    return "$self->{namespace}$action";
}

sub _build_action {
    my $self = shift;
    my ($class, @args) = @_;

    return $class->new(@args);
}

1;
