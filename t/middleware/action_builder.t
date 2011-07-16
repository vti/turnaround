use strict;
use warnings;

use Test::More tests => 5;

use_ok('Lamework::Middleware::ActionBuilder');

use lib 't/lib';

use MyApp;

my $app = MyApp->new;

my $middleware = Lamework::Middleware::ActionBuilder->new(app => sub { },
    namespace => 'MyApp::Action::');

my $env = {};
$middleware->call($env);

$env = {'lamework.captures' => {}};
$middleware->call($env);

$env = {'lamework.captures' => {action => 'unknown'}};
$middleware->call($env);

$env = {'lamework.captures' => {action => 'with_syntax_errors'}};
eval { $middleware->call($env); };
ok $@;

$env = {'lamework.captures' => {action => 'die_during_run'}};
eval { $middleware->call($env); };
like $@ => qr/^here/;

$env = {'lamework.captures' => {action => 'foo'}};
$middleware->call($env);
is $env->{'foo'} => 1;

$env = {'lamework.captures' => {action => 'custom_response'}};
my $res = $middleware->call($env);
is_deeply $res =>
  [200, ['Content-Type' => 'text/html'], ['Custom response!']];
