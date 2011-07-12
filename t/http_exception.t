use strict;
use warnings;

use Test::More tests => 3;

use_ok('Lamework::HTTPException');

eval { Lamework::HTTPException->throw(500, 'hello!'); };
isa_ok($@, 'Lamework::HTTPException');
is "$@", 'hello!';
