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
        $ioc->register('foo', class => 'Foo');

        isa_ok($ioc->get('foo'), 'Foo');
    };

    it "should accept hash references" => sub {
        $ioc->register('foo', {class => 'Foo'});

        isa_ok($ioc->get('foo'), 'Foo');
    };

    it "should hold constants" => sub {
        $ioc->register('foo', 'Foo');

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

        is_deeply([$ioc->get_all], [bar => $service2, foo => $service1,]);
    };

    it "should resolve single dependency" => sub {
        $ioc->register('foo', class => 'Foo');
        $ioc->register('bar', class => 'Bar', deps => 'foo');

        isa_ok($ioc->get('bar')->foo, 'Foo');
    };

    it "should resolve multiple dependencies" => sub {
        $ioc->register('foo', 'Foo');
        $ioc->register('bar', class => 'Bar', deps => 'foo');
        $ioc->register('baz', class => 'Baz', deps => ['foo', 'bar']);

        isa_ok($ioc->get('baz')->foo, 'Foo');
        isa_ok($ioc->get('baz')->bar, 'Bar');
    };

    it "should resolve dependecy and pass it as other name" => sub {
        $ioc->register('some name', 'Foo');
        $ioc->register(
            'zzz',
            class   => 'Bar',
            deps    => {foo => 'some name'}
        );

        my $zzz = $ioc->get('zzz');

        isa_ok($zzz->foo, 'Foo');
    };

    it "should create via factory" => sub {
        $ioc->register('foo' => sub {'123'});

        is($ioc->get('foo'), '123');
    };

    it "should create via factory and pass deps" => sub {
        $ioc->register('dep' => '123');
        $ioc->register(
            'foo' => block => sub {
                my $ioc  = shift;
                my %args = @_;

                return $args{dep};
            },
            deps => 'dep'
        );

        is($ioc->get('foo'), '123');
    };

    it "should hold singletons" => sub {
        $ioc->register('foo', class => 'Foo');
        $ioc->register('bar', class => 'Bar', deps => 'foo');

        my $bar = $ioc->get('bar');
        isa_ok($bar,      'Bar');
        isa_ok($bar->foo, 'Foo');

        $bar->hello('there');
        is $bar->hello, 'there';

        $bar = $ioc->get('bar');
        is $bar->hello, 'there';
    };

    it "should hold prototypes" => sub {
        $ioc->register('bar', class => 'Bar', lifecycle => 'prototype');

        my $bar = $ioc->get('bar');

        $bar->hello('there');
        is $bar->hello, 'there';

        $bar = $ioc->get('bar');
        ok not defined $bar->hello;
    };
};

runtests unless caller;

1;
