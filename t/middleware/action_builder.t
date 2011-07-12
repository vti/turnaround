use strict;
use warnings;

use Test::More tests => 5;

use_ok('Lamework::Middleware::ActionBuilder');

use lib 't/lib';

use MyApp;
use Lamework::Env;
use Lamework::Registry;

my $app = MyApp->new;

my $middleware = Lamework::Middleware::ActionBuilder->new(app => sub { });

my $env = {};
$middleware->call($env);

Lamework::Env->new($env)->set_captures();
$middleware->call($env);

Lamework::Env->new($env)->set_captures(action => 'unknown');
$middleware->call($env);

Lamework::Env->new($env)->set_captures(action => 'with_syntax_errors');
eval { $middleware->call($env); };
ok $@;

Lamework::Env->new($env)->set_captures(action => 'die_during_run');
eval { $middleware->call($env); };
like $@ => qr/^here/;

Lamework::Env->new($env)->set_captures(action => 'foo');
$middleware->call($env);
is $env->{'foo'} => 1;

Lamework::Env->new($env)->set_captures(action => 'custom_response');
my $res = $middleware->call($env);
is_deeply $res =>
  [200, ['Content-Type' => 'text/html'], ['Custom response!']];
