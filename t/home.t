use strict;
use warnings;

use Test::More tests => 3;

use lib 't/lib';

use_ok('Lamework::Home');

my $home = Lamework::Home->new('/foo/bar');

is $home => '/foo/bar';

is($home->catfile('hello', 'there') => '/foo/bar/hello/there');
