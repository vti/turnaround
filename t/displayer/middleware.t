use strict;
use warnings;
use utf8;

use Test::More;
use Test::MonkeyMock;
use Test::Fatal;

use Encode ();
use Turnaround::Displayer;
use Turnaround::Renderer::Caml;
use Turnaround::Middleware::ViewDisplayer;

subtest 'throws when no displayer' => sub {
    my $services = Test::MonkeyMock->new;
    $services->mock(service => sub { });

    like
      exception { _build_middleware(displayer => undef, services => $services) }
    , qr/displayer required/;
};

subtest 'gets displayer from services' => sub {
    my $displayer = _build_displayer();
    my $services  = Test::MonkeyMock->new;
    $services->mock(service => sub { $displayer });

    ok !
      exception { _build_middleware(displayer => undef, services => $services) };
};

subtest 'throws on unknown template' => sub {
    my $mw = _build_middleware();

    my $env = _build_env(template => 'unknown');

    like(exception { $mw->call($env) }, qr/can't find/i);
};

subtest 'renders template' => sub {
    my $mw = _build_middleware();

    my $env = _build_env(
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
};

subtest 'render template with utf8' => sub {
    my $mw = _build_middleware();

    my $env = _build_env(
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
};

subtest 'does no encode when encoding undefined' => sub {
    my $mw = _build_middleware(encoding => undef);

    my $env = _build_env(
        template => 'template-utf8.caml',
        vars     => {hello => 'привет'}
    );

    my $res = $mw->call($env);

    is_deeply $res,
      [
        200,
        [
            'Content-Length' => 6,
            'Content-Type'   => 'text/html'
        ],
        ['привет']
      ];
};

subtest 'render template with layout' => sub {
    my $mw = _build_middleware();

    my $env = _build_env(
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
};

subtest 'gets template name from dispatched request' => sub {
    my $dr = Test::MonkeyMock->new;
    $dr->mock(action => sub {'template'});

    my $mw = _build_middleware();

    my $env = _build_env(
        'turnaround.dispatched_request' => $dr,
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
};

subtest 'does nothing when dispatched_request has no action' => sub {
    my $dr = Test::MonkeyMock->new;
    $dr->mock(action => sub {''});

    my $mw = _build_middleware();

    my $env = _build_env(
        'turnaround.dispatched_request' => $dr,
        vars     => {hello => 'there'},
        layout   => 'layout.caml'
    );

    my $res = $mw->call($env);

    is_deeply $res, [200, [], ['OK']];
};

subtest 'does nothing when no dispatched_request' => sub {
    my $mw = _build_middleware();

    my $env = _build_env(
        vars     => {hello => 'there'},
        layout   => 'layout.caml'
    );

    my $res = $mw->call($env);

    is_deeply $res, [200, [], ['OK']];
};

sub _build_env {
    my (%params) = @_;

    my $env = {};

    foreach my $param (keys %params) {
        if ($param =~ m/^turnaround/) {
            $env->{$param} = $params{$param};
        } else {
            $env->{"turnaround.displayer.$param"} = $params{$param};
        }
    }

    return $env;
}

sub _build_displayer {
    Turnaround::Displayer->new(
        renderer => Turnaround::Renderer::Caml->new(
            templates_path => 't/middleware/MiddlewareViewDisplayerTest/'
        )
    );
}

sub _build_middleware {
    my $displayer = _build_displayer();

    return Turnaround::Middleware::ViewDisplayer->new(
        app => sub { [200, [], ['OK']] },
        displayer => $displayer,
        @_
    );
}

done_testing;
