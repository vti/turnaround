use strict;
use warnings;
use utf8;

use Test::More tests => 6;

use_ok('Lamework::Middleware::ViewDisplayer');

use lib 't/lib';

use Lamework::Registry;
use Lamework::Displayer;
use Lamework::Renderer::Caml;

my $displayer = Lamework::Displayer->new(
    formats => {
        caml => Lamework::Renderer::Caml->new(templates_path => 't/displayer')
    }
);
Lamework::Registry->set(displayer => $displayer);

my $middleware = Lamework::Middleware::ViewDisplayer->new(app => sub { });

my $env = {};
$middleware->call($env);

$env = {};
Lamework::Env->new($env)->set_template('unknown.caml');
eval { $middleware->call($env); };
like $@ => qr/can't find/i;
ok $@;

$env = {};
Lamework::Env->new($env)->set_template('template.caml');
Lamework::Env->new($env)->set_var(hello => 'there');
is_deeply $middleware->call($env) =>
  [200, ['Content-Length' => 5, 'Content-Type' => 'text/html'], ['there']];

$env = {};
Lamework::Env->new($env)->set_layout('layout.caml');
Lamework::Env->new($env)->set_template('template.caml');
Lamework::Env->new($env)->set_var(hello => 'there');
is_deeply $middleware->call($env) => [
    200,
    ['Content-Length' => 18, 'Content-Type' => 'text/html; charset=utf-8'],
    ["Before\nthere\nAfter"]
];

$env = {};
Lamework::Env->new($env)->set_template('template-utf8.caml');
Lamework::Env->new($env)->set_var(hello => 'привет');
is_deeply $middleware->call($env) => [
    200,
    ['Content-Length' => 12, 'Content-Type' => 'text/html; charset=utf-8'],
    [Encode::encode_utf8('привет')]
];
