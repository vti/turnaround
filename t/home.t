use strict;
use warnings;

use Test::More tests => 3;
use File::Spec;

use lib 't/lib';

use_ok('Turnaround::Home');

my $home = Turnaround::Home->new(path => '/foo/bar');

is $home => '/foo/bar';

is($home->catfile('hello', 'there') => File::Spec->catfile('/foo/bar/hello/there'));
