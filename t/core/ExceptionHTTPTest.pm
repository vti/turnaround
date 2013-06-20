package ExceptionHTTPTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Turnaround::Exception::HTTP;

sub throw_correct_isa : Test {
    my $self = shift;

    isa_ok(
        exception {
            Turnaround::Exception::HTTP->throw('error', code => '500');
        },
        'Turnaround::Exception::HTTP'
    );
}

sub return_code : Test {
    my $self = shift;

    my $e = exception {
        Turnaround::Exception::HTTP->throw('foo', code => '400');
    };

    is($e->code, 400);
}

sub return_default_code : Test {
    my $self = shift;

    my $e = exception {
        Turnaround::Exception::HTTP->throw('foo');
    };

    is($e->code, 500);
}

1;
