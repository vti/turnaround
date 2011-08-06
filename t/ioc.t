use strict;
use warnings;

use lib 't/ioc';

use Test::Spec;

use Foo;

use_ok('Lamework::IOC');

describe "IOC" => sub {
    my $ioc;

    before each => sub {
        $ioc = Lamework::IOC->new;
    };

    it "should hold services" => sub {
        $ioc->register('foo', 'Foo');

        isa_ok($ioc->get_service('foo'), 'Foo');
    };

    it "should hold constants" => sub {
        $ioc->register_constant('foo', 'Foo');

        is($ioc->get_service('foo'), 'Foo');
    };

    it "should accept instance as a service" => sub {
        $ioc->register('foo', Foo->new);

        isa_ok($ioc->get_service('foo'), 'Foo');
    };

    it "should return all services on get_services" => sub {
        my $service1 = Foo->new;
        $ioc->register('foo', $service1);
        my $service2 = Foo->new;
        $ioc->register('bar', $service2);

        is_deeply($ioc->get_services, [foo => $service1, bar => $service2]);
    };

    it "should resolve dependency" => sub {
        $ioc->register('foo', 'Foo');
        $ioc->register('bar', 'Bar', deps => 'foo');

        isa_ok($ioc->get_service('bar')->foo, 'Foo');
    };

    it "should resolve dependencies" => sub {
        $ioc->register('foo', 'Foo');
        $ioc->register('bar', 'Bar', deps => 'foo');
        $ioc->register('baz', 'Baz', deps => ['foo', 'bar']);

        isa_ok($ioc->get_service('baz')->foo, 'Foo');
        isa_ok($ioc->get_service('baz')->bar, 'Bar');
    };

    it "should hold singletons" => sub {
        $ioc->register('foo', 'Foo');
        $ioc->register('bar', 'Bar', deps => 'foo');

        my $bar = $ioc->get_service('bar');
        isa_ok($bar,      'Bar');
        isa_ok($bar->foo, 'Foo');

        $bar->hello('there');
        is $bar->hello, 'there';

        $bar = $ioc->get_service('bar');
        is $bar->hello, 'there';
    };

    it "should create service every time on create_service" => sub {
        $ioc->register('foo', 'Foo');

        isa_ok($ioc->create_service('foo'), 'Foo');
    };

    it "should implement aliases" => sub {
        $ioc->register('foo', 'Foo');
        $ioc->register(
            'zzz'   => 'Bar',
            deps    => 'foo',
            aliases => {foo => 'foo'}
        );

        my $zzz = $ioc->get_service('zzz');

        isa_ok($zzz->foo, 'Foo');
    };

    it "should allow setters injection" => sub {
        $ioc->register('foo', 'Foo');
        $ioc->register(
            'bar'   => 'Setters',
            deps    => 'foo',
            setters => {foo => 'set_foo'}
        );

        my $bar = $ioc->get_service('bar');

        isa_ok($bar->get_foo, 'Foo');
    };

    it "should create methods when needed" => sub {
        my $object = Foo->new;
        $ioc = Lamework::IOC->new(infect => $object);
        $ioc->register('method');

        ok($object->can('method'));
    };
};

runtests unless caller;

1;
