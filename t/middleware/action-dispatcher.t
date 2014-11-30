use strict;
use warnings;

use lib 't/middleware/MiddlewareActionDispatcherTest';

use Test::More;
use Test::Fatal;

use Turnaround::DispatchedRequest;
use Turnaround::ActionFactory;
use Turnaround::Middleware::ActionDispatcher;

subtest 'do_nothing_when_no_action' => sub {
    my $mw = _build_middleware();

    my $res = $mw->call(_build_env());

    is_deeply($res, [200, [], ['OK']]);
};

subtest 'do_nothing_when_unknown_action' => sub {
    my $mw = _build_middleware();

    my $res = $mw->call(_build_env(action => 'unknown'));

    is_deeply($res, [200, [], ['OK']]);
};

subtest 'skip_when_no_response' => sub {
    my $mw = _build_middleware();

    my $res = $mw->call(_build_env(action => 'no_response'));

    is_deeply($res, [200, [], ['OK']]);
};

subtest 'run_action_with_custom_response' => sub {
    my $mw = _build_middleware();

    my $res = $mw->call(_build_env(action => 'custom_response'));

    is_deeply $res =>
      [200, ['Content-Type' => 'text/html'], ['Custom response!']];
};

subtest 'run_action_with_text_response' => sub {
    my $mw = _build_middleware();

    my $res = $mw->call(_build_env(action => 'text_response'));

    is_deeply $res =>
      [200, ['Content-Type' => 'text/html'], ['Text response!']];
};

sub _build_middleware {
    my (%params) = @_;

    return Turnaround::Middleware::ActionDispatcher->new(
        action_factory => Turnaround::ActionFactory->new(),
        app            => sub { [200, [], ['OK']] }
    );
}

sub _build_env {
    my (%params) = @_;

    my $env =
      {'turnaround.dispatched_request' =>
          Turnaround::DispatchedRequest->new(action => delete $params{action})};

    foreach my $key (keys %params) {
        $env->{"turnaround.$key"} = $params{$key};
    }

    return $env;
}

done_testing;
