package IOCTest;

use strict;
use warnings;

use base 'Test::Class';

use Test::More;

use Foo;

use Lamework::IOC;

sub make_fixup : Test(setup) {
    my $self = shift;

    $self->{ioc} = Lamework::IOC->new;
}

sub test_simple : Test {
    my $self = shift;

    $self->{ioc}->register('foo', 'Foo');

    isa_ok($self->{ioc}->get_service('foo'), 'Foo');
}

sub test_instance : Test {
    my $self = shift;

    $self->{ioc}->register('foo', Foo->new);

    isa_ok($self->{ioc}->get_service('foo'), 'Foo');
}

sub test_deps : Test {
    my $self = shift;

    my $ioc = $self->{ioc};

    $ioc->register('foo', 'Foo');
    $ioc->register('bar', 'Bar', deps => 'foo');

    isa_ok($ioc->get_service('bar')->foo, 'Foo');
}

sub test_deps_multi : Test(2) {
    my $self = shift;

    my $ioc = $self->{ioc};

    $ioc->register('foo', 'Foo');
    $ioc->register('bar', 'Bar', deps => 'foo');
    $ioc->register('baz', 'Baz', deps => ['foo', 'bar']);

    isa_ok($ioc->get_service('baz')->foo, 'Foo');
    isa_ok($ioc->get_service('baz')->bar, 'Bar');
}

sub test_shared : Test(4) {
    my $self = shift;

    my $ioc = $self->{ioc};

    $ioc->register('foo', 'Foo');
    $ioc->register('bar', 'Bar', deps => 'foo');

    my $bar = $ioc->get_service('bar');
    isa_ok($bar,      'Bar');
    isa_ok($bar->foo, 'Foo');

    $bar->hello('there');
    is $bar->hello, 'there';

    $bar = $ioc->get_service('bar');
    is $bar->hello, 'there';
}

sub test_not_shared : Test {
    my $self = shift;

    my $ioc = $self->{ioc};

    $ioc->register('foo', 'Foo');

    isa_ok($ioc->create_service('foo'), 'Foo');
}

sub test_aliases : Test {
    my $self = shift;

    my $ioc = $self->{ioc};

    $ioc->register('foo', 'Foo');
    $ioc->register(
        'zzz'   => 'Bar',
        deps    => 'foo',
        aliases => {foo => 'foo'}
    );

    my $zzz = $ioc->get_service('zzz');

    isa_ok($zzz->foo, 'Foo');
}

sub test_setters : Test {
    my $self = shift;

    my $ioc = $self->{ioc};

    $ioc->register('foo', 'Foo');
    $ioc->register(
        'bar'   => 'Setters',
        deps    => 'foo',
        setters => {foo => 'set_foo'}
    );

    my $bar = $ioc->get_service('bar');

    isa_ok($bar->get_foo, 'Foo');
}

1;
