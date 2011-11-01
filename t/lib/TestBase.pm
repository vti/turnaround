package TestBase;

use strict;
use warnings;

use base 'Test::Class';

sub startup : Test(startup) {
}

sub shutdown : Test(shutdown) {
}


1;
