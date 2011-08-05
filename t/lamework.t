use strict;
use warnings;

use Test::More tests => 4;

use lib 't/lib';

use_ok('Lamework');

use MyApp;

my $app = MyApp->new;

ok($app->ioc->get_service('home'));
ok($app->ioc->get_service('routes'));
ok($app->ioc->get_service('displayer'));

1;
