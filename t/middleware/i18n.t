package MyAppI18N::I18N::en;

use base 'MyAppI18N::I18N';

our %Lexicon = (
    _AUTO => 1
);

package MyAppI18N::I18N::ru;

use base 'MyAppI18N::I18N';

our %Lexicon = (
    'Hello' => 'Привет'
);

package main;

use strict;
use warnings;

use utf8;

use Test::More tests => 22;
use Test::MockObject;

use_ok('Lamework::Middleware::I18N');

use Lamework::Registry;

my $middleware = Lamework::Middleware::I18N->new(
    app       => sub { },
    namespace => 'MyAppI18N',
    languages => [qw/en ru/]
);

my $env = {PATH_INFO => ''};
$middleware->call($env);
is $env->{'lamework.i18n.language'}            => 'en';
is $env->{PATH_INFO}                           => '';
is $env->{'lamework.i18n.maketext'}->('Hello') => 'Hello';

$env = {PATH_INFO => '/'};
$middleware->call($env);
is $env->{'lamework.i18n.language'} => 'en';
is $env->{PATH_INFO}                => '/';

$env = {PATH_INFO => '/hello'};
$middleware->call($env);
is $env->{'lamework.i18n.language'} => 'en';
is $env->{PATH_INFO}                => '/hello';

$env = {PATH_INFO => '/enhello'};
$middleware->call($env);
is $env->{'lamework.i18n.language'} => 'en';
is $env->{PATH_INFO}                => '/enhello';

$env = {PATH_INFO => '/en'};
$middleware->call($env);
is $env->{'lamework.i18n.language'} => 'en';
is $env->{PATH_INFO}                => '/';

$env = {PATH_INFO => '/ru/'};
$middleware->call($env);
is $env->{'lamework.i18n.language'} => 'ru';
is $env->{PATH_INFO}                => '/';
is $env->{'lamework.i18n.maketext'}->('Hello') => 'Привет';
is $env->{'lamework.i18n.maketext'}->('Unknown') => 'Unknown';

$env = {PATH_INFO => '/ru/hello'};
$middleware->call($env);
is $env->{'lamework.i18n.language'} => 'ru';
is $env->{PATH_INFO}                => '/hello';

$env = {PATH_INFO => '/', HTTP_ACCEPT_LANGUAGE => 'en-us,en; q=0.5'};
$middleware->call($env);
is $env->{'lamework.i18n.language'} => 'en';
is $env->{PATH_INFO}                => '/';

$env = {PATH_INFO => '/', HTTP_ACCEPT_LANGUAGE => 'ru-ru,ru; q=0.5'};
$middleware->call($env);
is $env->{'lamework.i18n.language'} => 'ru';
is $env->{PATH_INFO}                => '/';
