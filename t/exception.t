use strict;
use warnings;

use Test::More tests => 6;

use_ok('Lamework::Exception');

eval { Lamework::Exception->throw('hello!'); };
isa_ok($@, 'Lamework::Exception');
is("$@", 'hello!');

eval { Lamework::Exception->throw(class => 'Foo::Bar', message => 'hello!'); };
isa_ok($@, 'Lamework::Exception::Foo::Bar');

eval { Lamework::Exception->throw(class => '+Foo::Bar', message => 'hello!'); };
isa_ok($@, 'Foo::Bar');

eval { Lamework::Exception->throw(class => '+Foo::Bar', message => 'hello!'); };
isa_ok($@, 'Foo::Bar');
