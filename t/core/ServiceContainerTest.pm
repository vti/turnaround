package ServiceContainerTest;

use strict;
use warnings;

use base 'TestBase';

use lib 't/core/ServiceContainerTest';

use Test::More;
use Test::Fatal;

use FooInstance;

use Turnaround::ServiceContainer;

sub throw_on_getting_unknown_service : Test {
    my $self = shift;

    my $c = $self->_build_container;

    like(exception { $c->service('foo') }, qr/unknown service 'foo'/i);
}

sub register_string_service : Test {
    my $self = shift;

    my $c = $self->_build_container;

    $c->register(foo => \'bar');

    is($c->service('foo'), 'bar');
}

sub register_class_service : Test {
    my $self = shift;

    my $c = $self->_build_container;

    $c->register(foo => 'FooInstance');

    isa_ok($c->service('foo'), 'FooInstance');
}

sub register_instance_service : Test {
    my $self = shift;

    my $c = $self->_build_container;

    $c->register(foo => FooInstance->new);

    isa_ok($c->service('foo'), 'FooInstance');
}

sub register_service_via_sub : Test {
    my $self = shift;

    my $c = $self->_build_container;

    $c->register(foo => sub {'foo'});

    is($c->service('foo'), 'foo');
}

sub create_instance_when_prototype : Test {
    my $self = shift;

    my $c = $self->_build_container;

    $c->register(foo => 'FooInstance', lifecycle => 'prototype');

    my $foo = $c->service('foo');

    $foo->set_bar('bar');

    ok(not defined $c->service('foo')->get_bar());
}

sub run_sub_when_prototype : Test {
    my $self = shift;

    my $c = $self->_build_container;

    my $i = 0;

    $c->register(foo => sub { ++$i }, lifecycle => 'prototype');

    $c->service('foo');
    $c->service('foo');

    is($i, 2);
}

sub create_instance_once_when_singletone : Test {
    my $self = shift;

    my $c = $self->_build_container;

    $c->register(foo => 'FooInstance');

    my $foo = $c->service('foo');

    $foo->set_bar('bar');

    is($c->service('foo')->get_bar(), 'bar');
}

sub dot_not_clone_when_signletone : Test {
    my $self = shift;

    my $c = $self->_build_container;

    $c->register(foo => FooInstance->new);

    my $foo = $c->service('foo');
    $foo->set_bar('bar');

    is($c->service('foo')->get_bar(), 'bar');
}

sub run_sub_once_when_singletone : Test {
    my $self = shift;

    my $c = $self->_build_container;

    my $i = 0;

    $c->register(foo => sub { ++$i });

    $c->service('foo');
    $c->service('foo');

    is($i, 1);
}

sub pass_deps : Test {
    my $self = shift;

    my $c = $self->_build_container;

    $c->register('bar' => \'123');

    $c->register(
        foo      => 'FooInstance',
        services => ['bar']
    );

    my $foo = $c->service('foo');

    is($c->service('foo')->get_bar(), '123');
}

sub pass_deps_aliased : Test {
    my $self = shift;

    my $c = $self->_build_container;

    $c->register('baz' => \'123');

    $c->register(
        foo      => 'FooInstance',
        services => ['baz' => {as => 'bar'}]
    );

    my $foo = $c->service('foo');

    is($c->service('foo')->get_bar(), '123');
}

sub pass_deps_raw : Test {
    my $self = shift;

    my $c = $self->_build_container;

    $c->register(
        foo      => 'FooInstance',
        services => ['bar' => {value => '123'}]
    );

    my $foo = $c->service('foo');

    is($c->service('foo')->get_bar(), '123');
}

sub _build_container {
    my $self = shift;

    return Turnaround::ServiceContainer->new(@_);
}

1;
