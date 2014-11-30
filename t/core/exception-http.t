use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Turnaround::Exception::HTTP;

subtest 'throw_correct_isa' => sub {
    isa_ok(
        exception {
            Turnaround::Exception::HTTP->throw('error', code => '500');
        },
        'Turnaround::Exception::HTTP'
    );
};

subtest 'return_code' => sub {
    my $e = exception {
        Turnaround::Exception::HTTP->throw('foo', code => '400');
    };

    is($e->code, 400);
};

subtest 'return_default_code' => sub {
    my $e = exception {
        Turnaround::Exception::HTTP->throw('foo');
    };

    is($e->code, 500);
};

done_testing;
