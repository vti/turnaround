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
}

sub build {
    my $self = shift;
    my ($action, @args) = @_;

    my $class = $self->_build_class_name($action);

    return try {
        Class::Load::load_class($class);

        return $class->new(env => $env);
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

1;
