package MiddlewareViewDisplayerTest;

use strict;
use warnings;
use utf8;

use base 'TestBase';

use Encode;
use Test::More;
use Test::Fatal;

use Turnaround::Displayer;
use Turnaround::Renderer::Caml;
use Turnaround::Middleware::ViewDisplayer;

sub throw_on_unknown_template : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;

    my $env = $self->_build_env(template => 'unknown');

    like(exception { $mw->call($env) }, qr/can't find/i);
}

sub render_template : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;

    my $env = $self->_build_env(
        template => 'template.caml',
        vars     => {hello => 'there'}
    );

    my $res = $mw->call($env);

    is_deeply $res,
      [
        200,
        ['Content-Length' => 5, 'Content-Type' => 'text/html; charset=utf-8'],
        ['there']
      ];
}

sub render_template_with_utf8 : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;

    my $env = $self->_build_env(
        template => 'template-utf8.caml',
        vars     => {hello => 'привет'}
    );

    my $res = $mw->call($env);

    is_deeply $res,
      [
        200,
        [
            'Content-Length' => 12,
            'Content-Type'   => 'text/html; charset=utf-8'
        ],
        [Encode::encode_utf8('привет')]
      ];
}

sub render_template_with_layout : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;

    my $env = $self->_build_env(
        template => 'template.caml',
        vars     => {hello => 'there'},
        layout   => 'layout.caml'
    );

    my $res = $mw->call($env);

    is_deeply $res,
      [
        200,
        [
            'Content-Length' => 18,
            'Content-Type'   => 'text/html; charset=utf-8'
        ],
        ["Before\nthere\nAfter"]
      ];
}

sub _build_env {
    my $self = shift;
    my (%params) = @_;

    my $env = {};

    foreach my $param (keys %params) {
        $env->{"turnaround.displayer.$param"} = $params{$param};
    }

    return $env;
}

sub _build_middleware {
    my $self = shift;

    my $displayer = Turnaround::Displayer->new(
        renderer => Turnaround::Renderer::Caml->new(
            templates_path => 't/middleware/MiddlewareViewDisplayerTest/'
        )
    );

    return Turnaround::Middleware::ViewDisplayer->new(
        app => sub { [200, [], ['OK']] },
        displayer => $displayer
    );
}

1;
