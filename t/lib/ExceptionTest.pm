package ExceptionTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Lamework::Exception;

sub throw_strings : Test {
    my $self = shift;

    is(exception { Lamework::Exception->throw('hello!'); }, 'hello!');
}

sub throw_default_message : Test {
    my $self = shift;

    is(exception { Lamework::Exception->throw; },
        'Exception: Lamework::Exception');
}

sub throw_namespaced_classes : Test {
    my $self = shift;

    isa_ok(
        exception {
            Lamework::Exception->throw(
                class   => 'Foo::Bar',
                message => 'hello!'
            );
        },
        'Lamework::Exception::Foo::Bar'
    );
}

sub throw_namespaced_classes_with_default_message : Test {
    my $self = shift;

    is(exception { Lamework::Exception->throw(class => 'Foo::Bar'); },
        'Exception: Lamework::Exception::Foo::Bar');
}

sub throw_absolute_classes : Test {
    my $self = shift;

    isa_ok(
        exception {
            Lamework::Exception->throw(
                class   => '+Foo::Bar',
                message => 'hello!'
            );
        },
        'Foo::Bar'
    );
}

sub throw_absolute_classes_with_default_message : Test {
    my $self = shift;

    is(exception { Lamework::Exception->throw(class => '+Foo::Bar'); },
        'Exception: Foo::Bar');
}

sub catch_exceptions : Test {
    my $self = shift;

    my $e = exception { Lamework::Exception->throw(class => '+Foo::Bar'); };

    ok(Lamework::Exception->caught($e));
}

sub catch_exceptions_by_isa : Test {
    my $self = shift;

    my $e = exception { Lamework::Exception->throw(class => 'Foo::Bar'); };

    ok(Lamework::Exception->caught($e, 'Foo::Bar'));
}

sub not_catch_exceptions_by_wrong_isa : Test {
    my $self = shift;

    my $e = exception { Lamework::Exception->throw(class => 'Foo::Bar'); };

    ok(!Lamework::Exception->caught($e, 'Foo::Baz'));
}

1;
