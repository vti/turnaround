package Action;
use base 'Lamework::Action';

package Foo;
use base 'Lamework::Base';

package main;

use strict;
use warnings;

use Test::Spec;

use_ok('Lamework::ActionScopeFactory');

describe 'An ActionScopeFactory' => sub {
    my $factory;

    before each => sub {
        $factory = Lamework::ActionScopeFactory->new;
    };

    it "should register actions" => sub {
        $factory->configure('Action');
        my $ioc = $factory->build('Action');
        ok($ioc);
    };

    it "should build an IOC" => sub {
        $factory->configure('Action', ['foo' => 'Foo']);
        my $ioc = $factory->build('Action');
        my $foo = $ioc->get_service('foo');
        ok($foo);
    };
};

runtests unless caller;
