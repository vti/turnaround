use strict;
use warnings;
use utf8;

use Test::More;
use Test::Fatal;

use Encode ();

use Turnaround::Response;

subtest 'encode_body' => sub {
    my $res = _build_response(200);

    $res->body('привет');

    is_deeply(
        $res->finalize,
        [
            200,
            ['Content-Type' => 'text/html'],
            [Encode::encode('UTF-8', 'привет')]
        ]
    );
};

subtest 'set default content type' => sub {
    my $res = _build_response(200);

    is_deeply($res->finalize, [200, ['Content-Type' => 'text/html'], []]);
};

subtest 'not set default content type when present' => sub {
    my $res = _build_response(200);
    $res->content_type('text/plain');

    is_deeply($res->finalize, [200, ['Content-Type' => 'text/plain'], []]);
};

sub _build_response { Turnaround::Response->new(@_) }

done_testing;
