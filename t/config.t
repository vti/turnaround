use strict;
use warnings;

use Test::More tests => 3;

use_ok('Lamework::Config');

my $config = Lamework::Config->new;

eval { $config->load('unknown'); };
like $@ => qr/Can't open config file /;

is_deeply($config->load('t/config/config.ini'),
    {_ => {hello => 'there'}, main => {foo => 'bar'}});
