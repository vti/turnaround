package MiddlewareViewDisplayerTest;

use strict;
use warnings;
use utf8;

use base 'TestBase';

use Encode;
use Test::More;
use Test::Fatal;

use Lamework::Displayer;
use Lamework::Renderer::Caml;
use Lamework::Middleware::ViewDisplayer;

sub throw_on_unknown_template : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;

    my $env = {'lamework.template' => 'unknown'};

    like(exception { $mw->call($env) }, qr/can't find/i);
}

sub render_template : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;

    my $env = {
        'lamework.template' => 'template.caml',
        'lamework.vars'     => {hello => 'there'}
    };
    my $res = $mw->call($env);

    is_deeply $res,
      [200, ['Content-Length' => 5, 'Content-Type' => 'text/html'],
        ['there']];
}

sub render_template_with_utf8 : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;

    my $env = {
        'lamework.template' => 'template-utf8.caml',
        'lamework.vars'     => {hello => 'привет'}
    };
    my $res = $mw->call($env);

    is_deeply $res,
      [ 200,
        [   'Content-Length' => 12,
            'Content-Type'   => 'text/html; charset=utf-8'
        ],
        [Encode::encode_utf8('привет')]
      ];
}

sub render_template_with_layout : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;

    my $env = {
        'lamework.template' => 'template.caml',
        'lamework.vars'     => {hello => 'there'},
        'lamework.layout'   => 'layout.caml'
    };
    my $res = $mw->call($env);

    is_deeply $res,
      [ 200,
        [   'Content-Length' => 18,
            'Content-Type'   => 'text/html; charset=utf-8'
        ],
        ["Before\nthere\nAfter"]
      ];
}

sub _build_middleware {
    my $self = shift;

    my $displayer =
      Lamework::Displayer->new(renderer =>
          Lamework::Renderer::Caml->new(templates_path => 't/displayer'));

    return Lamework::Middleware::ViewDisplayer->new(
        app => sub { [200, [], ['OK']] },
        displayer => $displayer
    );
}

1;
