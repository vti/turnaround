use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Turnaround::Exception::Base;

subtest 'stringify' => sub {
    my $e = exception { Turnaround::Exception::Base->throw('hi there') };

    is($e, 'hi there at t/core/exception.t line 10.');
};

subtest 'return_message' => sub {
    my $e = exception { Turnaround::Exception::Base->throw('hi there') };

    is($e->message, 'hi there');
};

subtest 'return_exception_class_when_no_message_was_passed' => sub {
    my $e = exception { Turnaround::Exception::Base->throw };

    like($e, qr/Exception: Turnaround::Exception::Base /);
};

done_testing;
