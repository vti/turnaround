package HTTPExceptionTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Lamework::Exception;

sub throw_correct_isa : Test {
    my $self = shift;

    isa_ok(exception { raise 'Lamework::HTTPException', code => '500' },
        'Lamework::HTTPException');
}

sub stingify_without_details : Test {
    my $self = shift;

    is( exception {
            raise 'Lamework::HTTPException', code => '500', message => 'foo';
        },
        'foo'
    );
}

1;
