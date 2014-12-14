package Turnaround::Middleware::SerializerJSON;

use strict;
use warnings;

use base 'Turnaround::Middleware';

use JSON         ();
use Scalar::Util ();
use Plack::Util  ();
use Turnaround::Request;
use Turnaround::Exception::HTTP;

sub call {
    my $self = shift;
    my ($env) = @_;

    my $method = $env->{REQUEST_METHOD};
    if ($method eq 'PUT' || $method eq 'POST') {
        my $req = Turnaround::Request->new($env);

        my $json = eval { JSON::decode_json($req->content) } || do {
            my $error = $@;

            return $self->_wrap_json_response(400, [], 'Invalid JSON');
        };

        $env->{'turnaround.serializer.json'} = {foo => 'bar'};
    }

    my $res = eval { $self->app->($env); } || do {
        my $error = $@;

        return $self->_wrap_json_response(500, [], 'Internal system error');
    };

    if (!Plack::Util::header_get($res->[1], 'Content-Type')) {
        return $self->_wrap_json_response($res->[0], $res->[1], $res->[2]->[0]);
    }

    return $res;
}

sub _wrap_json_response {
    my $self = shift;
    my ($code, $headers, $body) = @_;

    $body = {message => $body} unless ref $body;

    return [
        $code,
        [@$headers, 'Content-Type' => 'application/json'],
        [JSON::encode_json($body)]
    ];
}

1;
