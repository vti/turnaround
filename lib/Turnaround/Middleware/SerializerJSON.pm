package Turnaround::Middleware::SerializerJSON;

use strict;
use warnings;

use base 'Turnaround::Middleware';

use JSON ();
use Turnaround::Request;
use Turnaround::Exception::HTTP;

sub call {
    my $self = shift;
    my ($env) = @_;

    my $method = $env->{REQUEST_METHOD};
    if ($method && $method =~ m/^(?:PUT|POST)$/) {
        my $req = Turnaround::Request->new($env);

        my $json = eval { JSON::decode_json($req->content) } || do {
            my $error = $@;

            Turnaround::Exception::HTTP->throw('Invalid JSON', code => 400);
        };

        $env->{'turnaround.serializer.json'} = {foo => 'bar'};
    }

    my $res = $self->app->($env);

    eval { $res->[2] = [JSON::encode_json($res->[2]->[0])] } || do {
        Turnaround::Exception::HTTP->throw('Internal system error', code => 500);
    };

    return $res;
}

1;
