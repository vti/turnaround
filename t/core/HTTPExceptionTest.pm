package HTTPExceptionTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Turnaround::HTTPException;

sub throw_correct_isa : Test {
    my $self = shift;

    isa_ok(exception { Turnaround::HTTPException->throw(code => '500') },
        'Turnaround::HTTPException');
}

sub stingify_without_details : Test {
    my $self = shift;

    is(
        exception {
            Turnaround::HTTPException->throw(code => '500', message => 'foo');
        },
        'foo'
    );
}

1;
