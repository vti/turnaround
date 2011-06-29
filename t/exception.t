use strict;
use warnings;

use Test::More tests => 3;

use_ok('Lamework::Exception');

eval { Lamework::Exception->throw('hello!'); };
isa_ok($@, 'Lamework::Exception');

eval { Lamework::Exception->throw(class => 'Foo::Bar', error => 'hello!'); };
isa_ok($@, 'Foo::Bar');
