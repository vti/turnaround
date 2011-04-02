use strict;
use warnings;

use Test::More tests => 7;

use_ok('Lamework::Registry');

Lamework::Registry->set(foo => 'bar');
is(Lamework::Registry->get('foo'), 'bar');

is(Lamework::Registry->get('unknown'), undef);

my $foo = {foo => 'bar'};
Lamework::Registry->set(foo => $foo);
is_deeply(Lamework::Registry->get('foo'), {foo => 'bar'});
undef $foo;
is_deeply(Lamework::Registry->get('foo'), {foo => 'bar'});

$foo = {foo => 'bar'};
Lamework::Registry->set_weaken(foo => $foo);
is_deeply(Lamework::Registry->get('foo'), {foo => 'bar'});
undef $foo;
is(Lamework::Registry->get('foo'), undef);
