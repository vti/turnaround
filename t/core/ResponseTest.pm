package ResponseTest;

use strict;
use warnings;
use utf8;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Encode;

use Turnaround::Response;

sub encode_body : Test {
    my $self = shift;

    my $res = $self->_build_response(200);

    $res->body('привет');

    is_deeply(
        $res->finalize,
        [   200,
            ['Content-Type' => 'text/html'],
            [Encode::encode('UTF-8', 'привет')]
        ]
    );
}

sub _build_response {
    my $self = shift;

    return Turnaround::Response->new(@_);
}

1;
