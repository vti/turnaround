package Lamework::Middleware::ACL;

use strict;
use warnings;

use base 'Lamework::Middleware';

use Scalar::Util qw(blessed);

use Lamework::HTTPException;

sub call {
    my $self = shift;
    my ($env) = @_;

    my $res = $self->_acl($env);
    return $res if $res;

    return $self->app->($env);
}

sub _acl {
    my $self = shift;
    my ($env) = @_;

    return $self->_deny unless my $user = $env->{user};

    my $action = $self->_get_action($env);

    my $role = blessed $user ? $user->role : $user->{role};

    return $self->_deny unless $self->{acl}->is_allowed($role, $action);
}

sub _get_action {
    my $self = shift;
    my ($env) = @_;

    my $dispatched_request = $env->{'lamework.dispatched_request'};

    die 'No DispatchedRequest found' unless $dispatched_request;

    return $dispatched_request->captures->{action};
}

sub _deny {
    my $self = shift;

    if (my $redirect_to = $self->{redirect_to}) {
        return [302, ['Location' => $redirect_to], ['']];
    }

    Lamework::HTTPException->throw(403);
}

1;
