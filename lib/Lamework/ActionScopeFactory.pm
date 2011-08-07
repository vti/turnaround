package Lamework::ActionScopeFactory;

use strict;
use warnings;

use base 'Lamework::Base';

use Lamework::IOC;

sub BUILD {
    my $self = shift;

    $self->{namespace} = '' unless defined $self->{namespace};
}

sub build {
    my $self = shift;
    my ($action) = @_;

    return unless exists $self->{$action};

    my $scope = $self->_build_scope;

    foreach my $dep (@{$self->{$action}}) {
        $scope->register(@$dep);
    }

    return $scope;
}

sub configure {
    my $self = shift;
    my ($action, @deps) = @_;

    $self->{"$self->{namespace}$action"} = [@deps];
}

sub _build_scope {
    my $self = shift;

    return Lamework::IOC->new(@_);
}

1;
