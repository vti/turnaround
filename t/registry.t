package Foo;
use base 'Lamework::Base';

package Bar;
use base 'Lamework::Base';

package main;

use strict;
use warnings;

use Test::Spec;

use_ok('Lamework::Registry');

describe 'Registry' => sub {
    it 'should accept object and create new instance' => sub {
        my $instance = Lamework::Registry->instance(Foo->new);
        ok($instance);
    };

    it 'should use process number when object not passed' => sub {
        my $instance = Lamework::Registry->instance;
        ok($instance);
    };

    it 'should not accept undef value' => sub {
        eval { Lamework::Registry->instance(undef) };
        ok($@);
    };

    it 'should return the same instance on the same object' => sub {
        my $foo       = Foo->new;
        my $instance1 = Lamework::Registry->instance($foo);
        my $instance2 = Lamework::Registry->instance($foo);
        is($instance1, $instance2);
    };

    it 'should hold another objects' => sub {
        my $foo      = Foo->new;
        my $bar      = Bar->new;
        my $instance = Lamework::Registry->instance($foo);
        $instance->set(bar => $bar);

        $instance = Lamework::Registry->instance($foo);
        is($instance->get('bar'), $bar);
    };

    it 'should hold factories' => sub {
        my $foo      = Foo->new;
        my $bar      = Bar->new;
        my $instance = Lamework::Registry->instance($foo);
        $instance->set(bar => sub {$bar});

        $instance = Lamework::Registry->instance($foo);
        is($instance->get('bar'), $bar);
    };

    it 'should forget about registry' => sub {
        my $foo       = Foo->new;
        my $instance1 = Lamework::Registry->instance($foo);
        Lamework::Registry->forget($foo);
        my $instance2 = Lamework::Registry->instance($foo);
        isnt($instance1, $instance2);
    };
};

runtests unless caller;
