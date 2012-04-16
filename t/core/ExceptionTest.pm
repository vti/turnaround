package ExceptionTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Carp ();
use Turnaround::Exception;

sub raise_objects_from_simple_die : Test {
    my $self = shift;

    my $e = exception { die 'hello' };

    isa_ok($e, 'Turnaround::Exception::Base');
}

sub raise_objects_from_carp : Test {
    my $self = shift;

    my $e = exception { Carp::croak('hello') };

    isa_ok($e, 'Turnaround::Exception::Base');
}

sub propagate_object_exceptions : Test {
    my $self = shift;

    my $e = exception { raise };

    isa_ok($e, 'Turnaround::Exception::Base');
}

sub record_caller_from_string_exceptions : Test(2) {
    my $self = shift;

    eval {
        die 'hello';
    }
    or do {
        my $e = $@;

        is $e->line, __LINE__ - 5;
        is $e->path, 't/core/ExceptionTest.pm';
    };
}

sub record_caller_from_object_exceptions : Test(2) {
    my $self = shift;

    eval {
        raise;
    }
    or do {
        my $e = $@;

        is $e->line, __LINE__ - 5;
        is $e->path, 't/core/ExceptionTest.pm';
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

    like(exception { raise 'Turnaround::Exception::Base' => 'hello!'; }, qr/^hello!/);
}

sub throw_default_message : Test {
    my $self = shift;

    like(exception { raise }, qr/^Exception: Turnaround::Exception::Base/);
}

1;
