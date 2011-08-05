use strict;
use warnings;
use utf8;

use Test::More tests => 6;

use_ok('Lamework::Middleware::ViewDisplayer');

use lib 't/lib';

use Lamework::Displayer;
use Lamework::Renderer::Caml;

my $displayer =
  Lamework::Displayer->new(
    renderer => Lamework::Renderer::Caml->new(templates_path => 't/displayer')
  );

my $middleware = Lamework::Middleware::ViewDisplayer->new(
    app       => sub { },
    displayer => $displayer
);

my $env = {};
$middleware->call($env);

$env = {'lamework.displayer' => {template => 'unknown.caml'}};
eval { $middleware->call($env); };
like $@ => qr/can't find/i;
ok $@;

$env = {
    'lamework.displayer' => {
        template => 'template.caml',
        vars     => {hello => 'there'}
    }
};
is_deeply $middleware->call($env) =>
  [200, ['Content-Length' => 5, 'Content-Type' => 'text/html'], ['there']];

$env = {
    'lamework.displayer' => {
        layout   => 'layout.caml',
        template => 'template.caml',
        vars     => {hello => 'there'}
    }
};
is_deeply $middleware->call($env) => [
    200,
    ['Content-Length' => 18, 'Content-Type' => 'text/html; charset=utf-8'],
    ["Before\nthere\nAfter"]
];

$env = {
    'lamework.displayer' => {
        template => 'template-utf8.caml',
        vars     => {hello => 'привет'}
    }
};
is_deeply $middleware->call($env) => [
    200,
    ['Content-Length' => 12, 'Content-Type' => 'text/html; charset=utf-8'],
    [Encode::encode_utf8('привет')]
];
