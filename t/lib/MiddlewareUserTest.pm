package MiddlewareUserTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Lamework::Middleware::User;

sub set_anonymous_when_no_session : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;

    my $env = {};

    my $res = $mw->call($env);

    is($env->{user}->role, 'anonymous');
}

sub set_anonymous_when_session_but_no_user : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;

    my $env = {'psgix.session' => {foo => 'bar'}};

    my $res = $mw->call($env);

    is($env->{user}->role, 'anonymous');
}

sub set_anonymous_when_user_not_found : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;

    my $env = {'psgix.session' => {user => 'unknown'}};

    my $res = $mw->call($env);

    is($env->{user}->role, 'anonymous');
}

sub set_user : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;

    my $env = {'psgix.session' => {user => 'user'}};

    my $res = $mw->call($env);

    is($env->{user}->role, 'user');
}

sub _build_middleware {
    my $self = shift;

    return Lamework::Middleware::User->new(
        app => sub { [200, [], ['OK']] },
        user_loader => sub {
            my $params = shift;

            if ($params eq 'user') {
                return TestUser->new(role => 'user');
            }

            return;
        }
    );
}

package TestUser;

use base 'Lamework::Base';

sub role { shift->{role} }

1;
