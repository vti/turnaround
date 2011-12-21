package ExceptionTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Lamework::Exception;

sub throw_strings : Test {
    my $self = shift;

    like(exception { throw 'Lamework::Exception' => 'hello!'; }, qr/^hello!/);
}

sub throw_default_message : Test {
    my $self = shift;

    like(exception { throw }, qr/^Exception: Lamework::Exception/);
}

sub throw_line : Test {
    my $self = shift;

    my $e = exception { throw };

    is($e->line, __LINE__ - 2);
}

sub throw_path : Test {
    my $self = shift;

    my $e = exception { throw };

    is($e->path, 't/lib/ExceptionTest.pm');
}

sub catch_exceptions : Test {
    my $self = shift;

    my $e = exception { throw 'Foo::Bar' };

    ok(caught($e => 'Foo::Bar'));
}

sub catch_exceptions_by_isa : Test {
    my $self = shift;

    my $e = exception { throw 'Foo::Bar' };

    ok(caught($e => 'Foo::Bar'));
}

sub not_catch_exceptions_by_wrong_isa : Test {
    my $self = shift;

    my $e = exception { throw 'Foo::Bar' };

    ok(!caught($e, 'Foo::Baz'));
}

1;
