package Lamework::ACL::Loader;

use strict;
use warnings;

use base 'Lamework::Base';

use YAML::Tiny;
use Lamework::ACL;

sub BUILD {
    my $self = shift;

    $self->{acl} ||= Lamework::ACL->new;
}

sub load {
    my $self = shift;
    $self = $self->new unless ref $self;
    my ($config) = @_;

    my $acl = $self->{acl};

    my $yaml = YAML::Tiny->read($config) or die $YAML::Tiny::errstr;

    foreach my $role (@{$yaml->[0]->{roles}}) {
        $acl->add_role($role);
    }

    foreach my $role (keys %{$yaml->[0]->{allow}}) {
        foreach my $path (@{$yaml->[0]->{allow}->{$role}}) {
            $acl->allow($role, $path);
        }
    }

    foreach my $role (keys %{$yaml->[0]->{deny}}) {
        foreach my $path (@{$yaml->[0]->{deny}->{$role}}) {
            $acl->deny($role, $path);
        }
    }

    return $acl;
}

1;
