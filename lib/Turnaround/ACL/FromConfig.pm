package Turnaround::ACL::FromConfig;

use strict;
use warnings;

use base 'Turnaround::FromConfig';

use Turnaround::ACL;

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{acl} = $params{acl} || Turnaround::ACL->new;

    return $self;
}

sub _from_config {
    my $self = shift;
    my ($config) = @_;

    my $acl = $self->{acl};

    return $acl unless %$config;

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
