use strict;
use warnings;

use Test::More tests => 5;
use Test::MockObject;

use_ok('Lamework::Middleware::ActionBuilder');

use lib 't/lib';

use MyApp;
use Lamework::Registry;

my $app = MyApp->new;

my $middleware = Lamework::Middleware::ActionBuilder->new(app => sub { });

my $env = {};
$middleware->call($env);

my $m = _build_match();
$env = {'lamework.routes.match' => $m};
$middleware->call($env);

$m = _build_match(action => 'unknown');
$env = {'lamework.routes.match' => $m};
$middleware->call($env);

$m = _build_match(action => 'with_syntax_errors');
$env = {'lamework.routes.match' => $m};
eval { $middleware->call($env); };
ok $@;

$m = _build_match(action => 'die_during_run');
$env = {'lamework.routes.match' => $m};
eval { $middleware->call($env); };
like $@ => qr/^here/;

$m = _build_match(action => 'foo');
$env = {'lamework.routes.match' => $m};
$middleware->call($env);
is $env->{'foo'} => 1;

$m = _build_match(action => 'custom_response');
$env = {'lamework.routes.match' => $m};
my $res = $middleware->call($env);
is_deeply $res => [
    200, ['Content-Length' => 16, 'Content-Type' => 'text/html'],
    ['Custom response!']
];

sub _build_match {
    my (@args) = @_;

    my $m = Test::MockObject->new;

    $m->mock(
        params => sub {
            return {@args};
        }
    );

    return $m;
}
