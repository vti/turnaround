package Lamework::ActionScopeFactory;

use strict;
use warnings;

use base 'Lamework::Base';

use Lamework::IOC;

sub build {
    my $self = shift;
    my ($action) = @_;

    return unless exists $self->{$action};

    my $ioc = $self->_build_ioc;

    foreach my $dep (@{$self->{$action}}) {
        $ioc->register(@$dep);
    }

    return $ioc;
}

sub configure {
    my $self = shift;
    my ($action, @deps) = @_;

    $self->{$action} = [@deps];
}

sub _build_ioc {
    my $self = shift;

    return Lamework::IOC->new(@_);
}

1;
