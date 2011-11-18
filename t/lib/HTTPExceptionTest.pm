package HTTPExceptionTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Lamework::HTTPException;

sub throw_correct_isa : Test {
    my $self = shift;

    isa_ok(exception { Lamework::HTTPException->throw(500, 'hello!') },
        'Lamework::HTTPException');
}

sub have_correct_message_when_stringified : Test {
    my $self = shift;

    is(exception { Lamework::HTTPException->throw(500, 'hello!') }, 'hello!');
}

1;
