package MiddlewareACLTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Lamework::ACL;
use Lamework::DispatchedRequest;
use Lamework::Middleware::ACL;

sub allow_when_role_is_correct : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;

    my $res =
      $mw->call($self->_build_env(user => {role => 'user'}, action => 'foo'));

    ok($res);
}

sub deny_when_unknown_role : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;

    ok( exception {
            $mw->call(
                $self->_build_env(user => {role => 'anon'}, action => 'bar'));
        }
    );
}

sub deny_when_denied_action : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;

    ok( exception {
            $mw->call(
                $self->_build_env(user => {role => 'user'}, action => 'bar'));
        }
    );
}

sub deny_when_no_user : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;

    ok(exception { $mw->call({}) });
}

sub _build_middleware {
    my $self = shift;

    my $acl = Lamework::ACL->new;

    $acl->add_role('user');
    $acl->allow('user', 'foo');

    return Lamework::Middleware::ACL->new(
        app => sub { [200, [], ['OK']] },
        acl => $acl
    );
}

sub _build_env {
    my $self   = shift;
    my %params = @_;

    my $action = delete $params{action};

    return {
        'lamework.dispatched_request' => Lamework::DispatchedRequest->new(
            captures => {action => $action}
        ),
        %params
    };
}

1;
