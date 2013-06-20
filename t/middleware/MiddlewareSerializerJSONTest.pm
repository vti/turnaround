package MiddlewareSerializerJSONTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Turnaround::Request;
use Turnaround::Middleware::SerializerJSON;

sub decode_JSON : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;

    my $json = '{"foo":"bar"}';
    open my $fh, '<', \$json;

    my $env = {
        REQUEST_METHOD => 'POST',
        CONTENT_TYPE   => 'application/json',
        CONTENT_LENGTH => length($json),
        'psgi.input'   => $fh
    };

    $mw->call($env);

    my $req = Turnaround::Request->new($env);

    is_deeply($env->{'turnaround.serializer.json'}, {foo => 'bar'});
}

sub return_when_cannot_decode_JSON : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;

    my $json = '{"foo""bar"}';
    open my $fh, '<', \$json;

    my $env = {
        REQUEST_METHOD => 'POST',
        CONTENT_TYPE   => 'application/json',
        CONTENT_LENGTH => length($json),
        'psgi.input'   => $fh
    };

    my $res = $mw->call($env);

    is_deeply(
        $res,
        [
            400,
            ['Content-Type' => 'application/json'],
            ['{"message":"Invalid JSON"}']
        ]
    );
}

sub catch_internal_exception : Test {
    my $self = shift;

    my $mw = $self->_build_middleware(app => sub { die 'error' });

    my $env = {REQUEST_METHOD => 'GET'};

    my $res = $mw->call($env);

    is_deeply(
        $res,
        [
            500,
            ['Content-Type' => 'application/json'],
            ['{"message":"Internal system error"}']
        ]
    );
}

sub encode_JSON : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;

    my $env = {REQUEST_METHOD => 'GET'};

    my $res = $mw->call($env);

    is_deeply($res,
        [200, ['Content-Type' => 'application/json'], ['{"foo":"bar"}']]);
}

sub not_encode_JSON_when_content_type : Test {
    my $self = shift;

    my $mw = $self->_build_middleware(
        app => sub { [200, ['Content-Type' => 'text/plain'], ['hi']] });

    my $env = {REQUEST_METHOD => 'GET'};

    my $res = $mw->call($env);

    is_deeply($res, [200, ['Content-Type' => 'text/plain'], ['hi']]);
}

sub _build_middleware {
    my $self = shift;

    return Turnaround::Middleware::SerializerJSON->new(
        app => sub { [200, [], [{foo => 'bar'}]] },
        @_
    );
}

1;
