use strict;
use warnings;

use lib 't/middleware/action_dispatcher_t';

use Test::More;
use Test::Fatal;
use Test::MonkeyMock;

use Turnaround::DispatchedRequest;
use Turnaround::ActionFactory;
use Turnaround::Middleware::ActionDispatcher;

subtest 'throws when no action_factory' => sub {
    my $services = Test::MonkeyMock->new;
    $services->mock(service => sub { });

    like exception {
        _build_middleware(services => $services, action_factory => undef)
    }, qr/action_factory required/;
};

subtest 'does nothing when no action' => sub {
    my $mw = _build_middleware();

    my $res = $mw->call(_build_env());

    is_deeply($res, [200, [], ['OK']]);
};

subtest 'does nothing when unknown action' => sub {
    my $mw = _build_middleware();

    my $res = $mw->call(_build_env(action => 'unknown'));

    is_deeply($res, [200, [], ['OK']]);
};

subtest 'does nothing when no dispatched request' => sub {
    my $mw = _build_middleware();

    my $res = $mw->call(_build_env('turnaround.dispatched_request' => undef));

    is_deeply($res, [200, [], ['OK']]);
};

subtest 'skips when no response' => sub {
    my $mw = _build_middleware();

    my $res = $mw->call(_build_env(action => 'no_response'));

    is_deeply($res, [200, [], ['OK']]);
};

subtest 'runs action with custom response' => sub {
    my $mw = _build_middleware();

    my $res = $mw->call(_build_env(action => 'custom_response'));

    is_deeply $res =>
      [200, ['Content-Type' => 'text/html'], ['Custom response!']];
};

subtest 'runs action with text response' => sub {
    my $mw = _build_middleware();

    my $res = $mw->call(_build_env(action => 'text_response'));

    is_deeply $res =>
      [200, ['Content-Type' => 'text/html'], ['Text response!']];
};

sub _build_middleware {
    my (%params) = @_;

    return Turnaround::Middleware::ActionDispatcher->new(
        action_factory => Turnaround::ActionFactory->new(),
        app            => sub { [200, [], ['OK']] },
        @_
    );
}

sub _build_env {
    my (%params) = @_;

    my $env =
      {'turnaround.dispatched_request' =>
          Turnaround::DispatchedRequest->new(action => delete $params{action})};

    foreach my $key (keys %params) {
        if ($key =~ m/^turnaround/) {
            $env->{$key} = $params{$key};
        }
        else {
            $env->{"turnaround.$key"} = $params{$key};
        }
    }

    return $env;
}

done_testing;
