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

        isa_ok($ioc->get('foo'), 'Foo');
    };

    it "should hold constants" => sub {
        $ioc->register_constant('foo', 'Foo');

        is($ioc->get('foo'), 'Foo');
    };

    it "should accept instance as a service" => sub {
        $ioc->register('foo', Foo->new);

        isa_ok($ioc->get('foo'), 'Foo');
    };

    it "should return all services on get_all" => sub {
        my $service1 = Foo->new;
        $ioc->register('foo', $service1);
        my $service2 = Foo->new;
        $ioc->register('bar', $service2);

        is_deeply($ioc->get_all, [foo => $service1, bar => $service2]);
    };

    it "should resolve dependency" => sub {
        $ioc->register('foo', 'Foo');
        $ioc->register('bar', 'Bar', deps => 'foo');

        isa_ok($ioc->get('bar')->foo, 'Foo');
    };

    it "should resolve dependencies" => sub {
        $ioc->register('foo', 'Foo');
        $ioc->register('bar', 'Bar', deps => 'foo');
        $ioc->register('baz', 'Baz', deps => ['foo', 'bar']);

        isa_ok($ioc->get('baz')->foo, 'Foo');
        isa_ok($ioc->get('baz')->bar, 'Bar');
    };

    it "should hold singletons" => sub {
        $ioc->register('foo', 'Foo');
        $ioc->register('bar', 'Bar', deps => 'foo');

        my $bar = $ioc->get('bar');
        isa_ok($bar,      'Bar');
        isa_ok($bar->foo, 'Foo');

        $bar->hello('there');
        is $bar->hello, 'there';

        $bar = $ioc->get('bar');
        is $bar->hello, 'there';
    };

    it "should create service every time on create" => sub {
        $ioc->register('foo', 'Foo');

        isa_ok($ioc->create('foo'), 'Foo');
    };

    it "should implement aliases" => sub {
        $ioc->register('foo', 'Foo');
        $ioc->register(
            'zzz'   => 'Bar',
            deps    => 'foo',
            aliases => {foo => 'foo'}
        );

        my $zzz = $ioc->get('zzz');

        isa_ok($zzz->foo, 'Foo');
    };

    it "should allow setters injection" => sub {
        $ioc->register('foo', 'Foo');
        $ioc->register(
            'bar'   => 'Setters',
            deps    => 'foo',
            setters => {foo => 'set_foo'}
        );

        my $bar = $ioc->get('bar');

        isa_ok($bar->get_foo, 'Foo');
    };
};

runtests unless caller;

1;
