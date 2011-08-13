package Lamework::ActionBuilder;

use strict;
use warnings;

use base 'Lamework::Base';

use Class::Load       ();
use String::CamelCase ();
use Try::Tiny;

use Lamework::IOC;

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

        return $self->_build_action($class, @args);
    }
    catch {
        $class =~ s{::}{/}g;

        die $_ unless $_ =~ m{^Can't locate $class\.pm in \@INC };

        return;
    };
}

sub configure {
    my $self = shift;
    my ($action, @deps) = @_;

    my $class = $self->_build_class_name($action);

    $self->{actions}->{$class} = {@deps};

    return $self;
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

    push @args, $self->_build_args($class);

    return $class->new(@args);
}

sub _build_args {
    my $self = shift;
    my ($class) = @_;

    return () unless exists $self->{actions}->{$class};

    my $scope = $self->_build_scope;

    my $deps = $self->{actions}->{$class};

    foreach my $key (%$deps) {
        $scope->register($key => $deps->{$key});
    }

    return $scope->get_all;
}

sub _build_scope {
    my $self = shift;

    return Lamework::IOC->new(@_);
}

1;
