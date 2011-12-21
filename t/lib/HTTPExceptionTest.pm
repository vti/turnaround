package HTTPExceptionTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Lamework::Exception;

sub throw_correct_isa : Test {
    my $self = shift;

    isa_ok(exception { throw 'Lamework::HTTPException', code => '500' },
        'Lamework::HTTPException');
}

1;
