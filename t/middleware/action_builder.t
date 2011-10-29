use strict;
use warnings;

use Test::More tests => 4;

use_ok('Lamework::Middleware::ActionBuilder');

use Lamework::ActionBuilder;
use Lamework::DispatchedRequest;

use lib 't/lib';

use MyApp;

my $app = MyApp->new;

my $middleware = Lamework::Middleware::ActionBuilder->new(
    app => sub { },
    action_builder =>
      Lamework::ActionBuilder->new(namespace => 'MyApp::Action::')
);

my $env = {};
$middleware->call($env);

$env =
  {'lamework.dispatched_request' =>
      Lamework::DispatchedRequest->new(captures => {})};
$middleware->call($env);

$env =
  {'lamework.dispatched_request' =>
      Lamework::DispatchedRequest->new(captures => {action => 'unknown'})};
$middleware->call($env);

$env = {
    'lamework.dispatched_request' => Lamework::DispatchedRequest->new(
        captures => {action => 'with_syntax_errors'}
    )
};
eval { $middleware->call($env); };
ok $@;

$env = {
    'lamework.dispatched_request' => Lamework::DispatchedRequest->new(
        captures => {action => 'die_during_run'}
    )
};
eval { $middleware->call($env); };
like $@ => qr/^here/;

$env = {
    'lamework.dispatched_request' => Lamework::DispatchedRequest->new(
        captures => {action => 'custom_response'}
    )
};
my $res = $middleware->call($env);
is_deeply $res =>
  [200, ['Content-Type' => 'text/html'], ['Custom response!']];
