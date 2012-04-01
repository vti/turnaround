package ExceptionTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Lamework::Exception;

sub raise_objects_from_simple_die : Test {
    my $self = shift;

    my $e = exception { die 'hello' };

    isa_ok($e, 'Lamework::Exception::Base');
}

sub propagate_object_exceptions : Test {
    my $self = shift;

    my $e = exception { raise };

    isa_ok($e, 'Lamework::Exception::Base');
}

sub record_caller_from_string_exceptions : Test(2) {
    my $self = shift;

    try {
        die 'hello';
    }
    catch {
        is $_->line, __LINE__ - 3;
        is $_->path, 't/lib/ExceptionTest.pm';
    };
}

sub record_caller_from_object_exceptions : Test(2) {
    my $self = shift;

    try {
        raise;
    }
    catch {
        is $_->line, __LINE__ - 3;
        is $_->path, 't/lib/ExceptionTest.pm';
    };
}

sub catch_exceptions_by_isa : Test {
    my $self = shift;

    my $e = exception { raise 'Foo::Bar' };

    ok($e->does('Foo::Bar'));
}

sub not_catch_exceptions_by_wrong_isa : Test {
    my $self = shift;

    my $e = exception { raise 'Foo::Bar' };

    ok(!$e->does('Foo::Baz'));
}

sub throw_messages : Test {
    my $self = shift;

    like(exception { raise 'Lamework::Exception::Base' => 'hello!'; }, qr/^hello!/);
}

sub throw_default_message : Test {
    my $self = shift;

    like(exception { raise }, qr/^Exception: Lamework::Exception::Base/);
}

1;
