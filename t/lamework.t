use strict;
use warnings;

use Test::More tests => 5;

use lib 't/lib';

use_ok('Lamework');

use MyApp;

my $app = MyApp->new;

is $app->namespace => 'MyApp';

ok $app->routes;

ok(Lamework::Registry->get('app'));
ok(Lamework::Registry->get('home'));
ok(Lamework::Registry->get('routes'));

1;
