use strict;
use warnings;

use Test::More tests => 4;

use_ok('Lamework::Config');
use_ok('Lamework::Config::Ini');

my $config = Lamework::Config->new(loader => Lamework::Config::Ini->new);

is_deeply $config->load('unknown'), {};

is_deeply($config->load('t/config/config.ini'),
    {_ => {hello => 'there'}, main => {foo => 'bar'}});
