use strict;
use warnings;

use Test::More tests => 7;

use_ok('Lamework::Env');

my $env = {foo => 'bar'};

$env = Lamework::Env->new($env);
is($env->{foo}, 'bar');
$env->{bar} = 'baz';
is($env->{bar}, 'baz');
is_deeply({%$env}, {foo => 'bar', bar => 'baz'});
is_deeply($env, {foo => 'bar', bar => 'baz'});

$env->set(hello => 'there');
is($env->get('hello'), 'there');
is($env->{hello}, 'there');
