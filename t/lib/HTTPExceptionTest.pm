package HTTPExceptionTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Turnaround::Exception;

sub throw_correct_isa : Test {
    my $self = shift;

    isa_ok(exception { raise 'Turnaround::HTTPException', code => '500' },
        'Turnaround::HTTPException');
}

sub stingify_without_details : Test {
    my $self = shift;

    is( exception {
            raise 'Turnaround::HTTPException', code => '500', message => 'foo';
        },
        'foo'
    );
}

1;
