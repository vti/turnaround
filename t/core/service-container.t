use strict;
use warnings;

use lib 't/core/ServiceContainerTest';

use Test::More;
use Test::Fatal;

use FooInstance;

use Turnaround::ServiceContainer;

subtest 'throw_on_getting_unknown_service' => sub {
    my $c = _build_container();

    like(exception { $c->service('foo') }, qr/unknown service 'foo'/i);
};

subtest 'register_string_service' => sub {
    my $c = _build_container();

    $c->register(foo => \'bar');

    is($c->service('foo'), 'bar');
};

subtest 'register_class_service' => sub {
    my $c = _build_container();

    $c->register(foo => 'FooInstance');

    isa_ok($c->service('foo'), 'FooInstance');
};

subtest 'register_instance_service' => sub {
    my $c = _build_container();

    $c->register(foo => FooInstance->new);

    isa_ok($c->service('foo'), 'FooInstance');
};

subtest 'register_service_via_sub' => sub {
    my $c = _build_container();

    $c->register(foo => sub { 'foo' });

    is($c->service('foo'), 'foo');
};

subtest 'create_instance_when_prototype' => sub {
    my $c = _build_container();

    $c->register(foo => 'FooInstance', lifecycle => 'prototype');

    my $foo = $c->service('foo');

    $foo->set_bar('bar');

    ok(not defined $c->service('foo')->get_bar());
};

subtest 'create_instance_when_prototype_with_passed_arguments' => sub {
    my $c = _build_container();

    $c->register(foo => 'FooInstance', lifecycle => 'prototype');

    is($c->service('foo', bar => 'baz')->get_bar(), 'baz');
};

subtest 'run_sub_when_prototype' => sub {
    my $c = _build_container();

    my $i = 0;

    $c->register(foo => sub { ++$i }, lifecycle => 'prototype');

    $c->service('foo');
    $c->service('foo');

    is($i, 2);
};

subtest 'create_instance_once_when_singletone' => sub {
    my $c = _build_container();

    $c->register(foo => 'FooInstance');

    my $foo = $c->service('foo');

    $foo->set_bar('bar');

    is($c->service('foo')->get_bar(), 'bar');
};

subtest 'dot_not_clone_when_signletone' => sub {
    my $c = _build_container();

    $c->register(foo => FooInstance->new);

    my $foo = $c->service('foo');
    $foo->set_bar('bar');

    is($c->service('foo')->get_bar(), 'bar');
};

subtest 'run_sub_once_when_singletone' => sub {
    my $c = _build_container();

    my $i = 0;

    $c->register(foo => sub { ++$i });

    $c->service('foo');
    $c->service('foo');

    is($i, 1);
};

subtest 'pass_deps' => sub {
    my $c = _build_container();

    $c->register('bar' => \'123');

    $c->register(
        foo      => 'FooInstance',
        services => ['bar']
    );

    my $foo = $c->service('foo');

    is($c->service('foo')->get_bar(), '123');
};

subtest 'pass_deps_aliased' => sub {
    my $c = _build_container();

    $c->register('baz' => \'123');

    $c->register(
        foo      => 'FooInstance',
        services => ['baz' => {as => 'bar'}]
    );

    my $foo = $c->service('foo');

    is($c->service('foo')->get_bar(), '123');
};

subtest 'pass_deps_raw' => sub {
    my $c = _build_container();

    $c->register(
        foo      => 'FooInstance',
        services => ['bar' => {value => '123'}]
    );

    my $foo = $c->service('foo');

    is($c->service('foo')->get_bar(), '123');
};

sub _build_container {
    return Turnaround::ServiceContainer->new(@_);
}

done_testing;
