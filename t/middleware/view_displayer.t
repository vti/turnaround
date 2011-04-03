use strict;
use warnings;
use utf8;

use Test::More tests => 3;
use Test::MockObject;

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

$env = {'lamework.displayer.template' => 'unknown.caml'};
eval { $middleware->call($env); };

$env = {
    'lamework.displayer.template' => 'template.caml',
    'lamework.displayer.vars'     => {hello => 'there'}
};
my $res = $middleware->call($env);
is_deeply $res =>
  [200, ['Content-Length' => 5, 'Content-Type' => 'text/html'], ['there']];

$env = {
    'lamework.displayer.template' => 'template-utf8.caml',
    'lamework.displayer.vars'     => {hello => 'привет'}
};
$res = $middleware->call($env);
is_deeply $res => [
    200,
    ['Content-Length' => 12, 'Content-Type' => 'text/html; charset=utf-8'],
    [Encode::encode_utf8('привет')]
];
