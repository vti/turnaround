use strict;
use warnings;
use utf8;

use Test::More tests => 6;

use_ok('Lamework::Middleware::ViewDisplayer');

use lib 't/lib';

use Lamework::IOC;
use Lamework::Displayer;
use Lamework::Renderer::Caml;

my $displayer = Lamework::Displayer->new;
$displayer->add_format(
    caml => Lamework::Renderer::Caml->new(templates_path => 't/displayer'));

my $ioc = Lamework::IOC->new;
$ioc->register(displayer => $displayer);

my $middleware = Lamework::Middleware::ViewDisplayer->new(app => sub { });

my $env = {};
$middleware->call($env);

$env = {
    'lamework.ioc'       => $ioc,
    'lamework.displayer' => {template => 'unknown.caml'}
};
eval { $middleware->call($env); };
like $@ => qr/can't find/i;
ok $@;

$env = {
    'lamework.ioc'       => $ioc,
    'lamework.displayer' => {
        template => 'template.caml',
        vars     => {hello => 'there'}
    }
};
is_deeply $middleware->call($env) =>
  [200, ['Content-Length' => 5, 'Content-Type' => 'text/html'], ['there']];

$env = {
    'lamework.ioc'       => $ioc,
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
    'lamework.ioc'       => $ioc,
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
