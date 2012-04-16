#!/usr/bin/env perl

use lib 't/lib';

use TestLoader qw(t/middleware);

BEGIN { $ENV{TEST_SUITE} = 1 }

Test::Class->runtests;
