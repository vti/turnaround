use strict;
use warnings;

use Test::More tests => 3;

use_ok('Lamework::Config');

my $config = Lamework::Config->new;

is_deeply $config->load('unknown'), {};

is_deeply($config->load('t/config/config.ini'),
    {_ => {hello => 'there'}, main => {foo => 'bar'}});
