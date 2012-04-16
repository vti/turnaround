package Turnaround::ACL::ConfigLoader;

use strict;
use warnings;

use base 'Turnaround::Config';

use Turnaround::ACL;

sub BUILD {
    my $self = shift;

    $self->SUPER::BUILD();

    $self->{acl} ||= Turnaround::ACL->new;
}

sub load {
    my $self = shift;

    my $acl = $self->{acl};

    my $config = $self->SUPER::load(@_);
    return $acl unless $config && ref $config eq 'HASH';

    foreach my $role (@{$config->{roles}}) {
        $acl->add_role($role);
    }

    foreach my $role (keys %{$config->{allow}}) {
        foreach my $path (@{$config->{allow}->{$role}}) {
            $acl->allow($role, $path);
        }
    }

    foreach my $role (keys %{$config->{deny}}) {
        foreach my $path (@{$config->{deny}->{$role}}) {
            $acl->deny($role, $path);
        }
    }

    return $acl;
}

1;
