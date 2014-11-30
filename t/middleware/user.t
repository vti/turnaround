use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Turnaround::Middleware::User;

subtest 'set_anonymous_when_no_session' => sub {
    my $mw = _build_middleware();

    my $env = {};

    my $res = $mw->call($env);

    is($env->{'turnaround.user'}->role, 'anonymous');
};

subtest 'set_anonymous_when_session_but_no_user' => sub {
    my $mw = _build_middleware();

    my $env = {'psgix.session' => {foo => 'bar'}};

    my $res = $mw->call($env);

    is($env->{'turnaround.user'}->role, 'anonymous');
};

subtest 'set_anonymous_when_user_not_found' => sub {
    my $mw = _build_middleware();

    my $env = {'psgix.session' => {user => 'unknown'}};

    my $res = $mw->call($env);

    is($env->{'turnaround.user'}->role, 'anonymous');
};

subtest 'set_user' => sub {
    my $mw = _build_middleware();

    my $env = {'psgix.session' => {user => 'user'}};

    my $res = $mw->call($env);

    is($env->{'turnaround.user'}->role, 'user');
};

sub _build_middleware {
    return Turnaround::Middleware::User->new(
        app => sub { [200, [], ['OK']] },
        user_loader => sub {
            my $session = shift;

            if ($session->{user} && $session->{user} eq 'user') {
                return TestUser->new(role => 'user');
            }

            return;
        }
    );
}

done_testing;

package TestUser;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{role} = $params{role};

    return $self;
}

sub role { shift->{role} }
