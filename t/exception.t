use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Turnaround::Exception::Base;

subtest 'stringifies' => sub {
    my $e = exception { Turnaround::Exception::Base->throw('hi there') };

    is $e, 'hi there at t/exception.t line 10.';
};

subtest 'returns message' => sub {
    my $e = exception { Turnaround::Exception::Base->throw('hi there') };

    is $e->message, 'hi there';
};

subtest 'returns exception class when no message was passed' => sub {
    my $e = exception { Turnaround::Exception::Base->throw };

    like $e, qr/Exception: Turnaround::Exception::Base /;
};

done_testing;
