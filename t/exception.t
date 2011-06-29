use strict;
use warnings;

use Test::More tests => 4;

use_ok('Lamework::Exception');

eval { Lamework::Exception->throw('hello!'); };
isa_ok($@, 'Lamework::Exception');

eval { Lamework::Exception->throw(class => 'Foo::Bar', error => 'hello!'); };
isa_ok($@, 'Lamework::Exception::Foo::Bar');

eval { Lamework::Exception->throw(class => '+Foo::Bar', error => 'hello!'); };
isa_ok($@, 'Foo::Bar');
