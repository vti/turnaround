package Turnaround::Plugin::ACL;

use strict;
use warnings;

use base 'Turnaround::Plugin';

use Carp qw(croak);
use Turnaround::ACL::FromConfig;

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{user_loader} = $params{user_loader}
      || croak('$user_loader required');

    return $self;
}

sub startup {
    my $self = shift;

    $self->builder->insert_before_middleware('RequestDispatcher',
        'Session::Cookie', services => $self->services);

    $self->builder->insert_before_middleware(
        'RequestDispatcher', 'User',
        services    => $self->services,
        user_loader => $self->{user_loader}
    );

    my $acl = Turnaround::ACL::FromConfig->new->load('config/acl.yml');
    $self->builder->insert_before_middleware(
        'ActionDispatcher', 'ACL',
        services => $self->services,
        acl      => $acl
    );
}

1;
