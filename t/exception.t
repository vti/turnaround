use strict;
use warnings;

use Test::Spec;

use_ok('Lamework::Exception');

describe "An exception" => sub {
    it "should throw strings" => sub {
        eval { Lamework::Exception->throw('hello!'); };
        is("$@", 'hello!');
    };

    it "should throw namespaced classes" => sub {
        eval {
            Lamework::Exception->throw(
                class   => 'Foo::Bar',
                message => 'hello!'
            );
        };
        is(ref $@, 'Lamework::Exception::Foo::Bar');
    };

    it "should throw absolute classes" => sub {
        eval {
            Lamework::Exception->throw(
                class   => '+Foo::Bar',
                message => 'hello!'
            );
        };
        is(ref $@, 'Foo::Bar');
    };
};

runtests unless caller;
