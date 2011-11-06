package Lamework::Middleware::ACL;

use strict;
use warnings;

use base 'Lamework::Middleware';

use Scalar::Util qw(blessed);

use Lamework::HTTPException;

sub call {
    my $self = shift;
    my ($env) = @_;

    $self->_acl($env);

    return $self->app->($env);
}

sub _acl {
    my $self = shift;
    my ($env) = @_;

    $self->_throw_403 unless my $user = $env->{user};

    my $action = $self->_get_action($env);

    my $role = blessed $user ? $user->role : $user->{role};

    $self->_throw_403 unless $self->{acl}->is_allowed($role, $action);
}

sub _get_action {
    my $self = shift;
    my ($env) = @_;

    my $dispatched_request = $env->{'lamework.dispatched_request'};

    die 'No DispatchedRequest found' unless $dispatched_request;

    return $dispatched_request->captures->{action};
}

sub _throw_403 {
    my $self = shift;

    Lamework::HTTPException->throw(403);
}

1;
