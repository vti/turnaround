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

sub throw_when_cannot_decode_JSON : Test {
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

    my $e = exception { $mw->call($env) };

    is $e->code, 400;
}

sub encode_JSON : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;

    my $env = {REQUEST_METHOD => 'GET'};

    my $res = $mw->call($env);

    is_deeply($res, [200, [], ['{"foo":"bar"}']]);
}

sub throw_when_cannot_encode_JSON : Test {
    my $self = shift;

    my $mw = $self->_build_middleware(app => sub { [200, [], ['123']] });

    my $env = {REQUEST_METHOD => 'GET'};

    my $e = exception { $mw->call($env) };

    is $e->code, 500;
}

sub _build_middleware {
    my $self = shift;

    return Turnaround::Middleware::SerializerJSON->new(
        app => sub { [200, [], [{foo => 'bar'}]] },
        @_
    );
}

1;
