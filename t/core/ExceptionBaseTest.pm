package ExceptionBaseTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Turnaround::Exception::Base;

sub stringify : Test {
    my $self = shift;

    my $e = exception { Turnaround::Exception::Base->throw('hi there') };

    is($e, 'hi there at t/core/ExceptionBaseTest.pm line 16.');
}

sub return_message : Test {
    my $self = shift;

    my $e = exception { Turnaround::Exception::Base->throw('hi there') };

    is($e->message, 'hi there');
}

sub return_exception_class_when_no_message_was_passed : Test {
    my $self = shift;

    my $e = exception { Turnaround::Exception::Base->throw };

    like($e, qr/Exception: Turnaround::Exception::Base /);
}

1;
