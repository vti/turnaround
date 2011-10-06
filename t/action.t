package Action;

use base 'Lamework::Action';

sub run {1}

package main;

use strict;
use warnings;

use Test::More tests => 2;

use_ok('Lamework::Action');

my $action = Action->new;

ok $action->run;
