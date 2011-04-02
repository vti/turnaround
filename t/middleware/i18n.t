use strict;
use warnings;

use Test::More tests => 19;
use Test::MockObject;

use_ok('Lamework::Middleware::I18N');

use Lamework::Registry;

my $middleware =
  Lamework::Middleware::I18N->new(app => sub { }, languages => [qw/en ru/]);

my $env = {PATH_INFO => ''};
$middleware->call($env);
is $env->{'lamework.i18n.language'} => 'en';
is $env->{PATH_INFO} => '';

$env = {PATH_INFO => '/'};
$middleware->call($env);
is $env->{'lamework.i18n.language'} => 'en';
is $env->{PATH_INFO} => '/';

$env = {PATH_INFO => '/hello'};
$middleware->call($env);
is $env->{'lamework.i18n.language'} => 'en';
is $env->{PATH_INFO} => '/hello';

$env = {PATH_INFO => '/enhello'};
$middleware->call($env);
is $env->{'lamework.i18n.language'} => 'en';
is $env->{PATH_INFO} => '/enhello';

$env = {PATH_INFO => '/en'};
$middleware->call($env);
is $env->{'lamework.i18n.language'} => 'en';
is $env->{PATH_INFO} => '/';

$env = {PATH_INFO => '/ru/'};
$middleware->call($env);
is $env->{'lamework.i18n.language'} => 'ru';
is $env->{PATH_INFO} => '/';

$env = {PATH_INFO => '/ru/hello'};
$middleware->call($env);
is $env->{'lamework.i18n.language'} => 'ru';
is $env->{PATH_INFO} => '/hello';

$env = {PATH_INFO => '/', HTTP_ACCEPT_LANGUAGE => 'en-us,en; q=0.5'};
$middleware->call($env);
is $env->{'lamework.i18n.language'} => 'en';
is $env->{PATH_INFO} => '/';

$env = {PATH_INFO => '/', HTTP_ACCEPT_LANGUAGE => 'ru-ru,ru; q=0.5'};
$middleware->call($env);
is $env->{'lamework.i18n.language'} => 'ru';
is $env->{PATH_INFO} => '/';
