package Turnaround::ACL::FromConfig;

use strict;
use warnings;

use base 'Turnaround::FromConfig';

use Turnaround::ACL;

sub BUILD {
    my $self = shift;

    $self->SUPER::BUILD();

    $self->{acl} ||= Turnaround::ACL->new;
}

sub _from_config {
    my $self = shift;
    my ($config) = @_;

    my $acl = $self->{acl};

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
