use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Turnaround::ACL;
use Turnaround::DispatchedRequest;
use Turnaround::Middleware::ACL;

subtest 'allow_when_role_is_correct' => sub {
    my $mw = _build_middleware();

    my $env = _build_env(user => {role => 'user'}, action => 'foo');

    my $res = $mw->call($env);

    ok($res);
};

subtest 'deny_when_unknown_role' => sub {
    my $mw = _build_middleware();

    ok(
        exception {
            $mw->call(_build_env(user => {role => 'anon'}, action => 'bar'));
        }
    );
};

subtest 'deny_when_denied_action' => sub {
    my $mw = _build_middleware();

    ok(
        exception {
            $mw->call(_build_env(user => {role => 'user'}, action => 'bar'));
        }
    );
};

subtest 'deny_when_no_user' => sub {
    my $mw = _build_middleware();

    ok(exception { $mw->call({}) });
};

subtest 'redirect_instead_of_throw' => sub {
    my $mw = _build_middleware(redirect_to => '/login');

    my $res = $mw->call({PATH_INFO => '/'});

    is_deeply($res, [302, ['Location' => '/login'], ['']]);
};

subtest 'prevent_redirect_recursion' => sub {
    my $mw = _build_middleware(redirect_to => '/login');

    ok(exception { $mw->call({PATH_INFO => '/login'}) });
};

sub _build_middleware {
    my $acl = Turnaround::ACL->new;

    $acl->add_role('user');
    $acl->allow('user', 'foo');

    return Turnaround::Middleware::ACL->new(
        app => sub { [200, [], ['OK']] },
        acl => $acl,
        @_
    );
}

sub _build_env {
    my %params = @_;

    my $action = delete $params{action};

    my $env = {};

    $env->{'turnaround.dispatched_request'} =
      Turnaround::DispatchedRequest->new(action => $action);

    foreach my $key (keys %params) {
        $env->{"turnaround.$key"} = $params{$key};
    }

    return $env;
}

done_testing;
