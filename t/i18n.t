use strict;
use warnings;
use utf8;

use lib 't/i18n_t';

use Test::More;
use Test::Requires;
use Test::Fatal;

BEGIN { test_requires 'I18N::AcceptLanguage' }

use Turnaround::I18N;

use I18NTest::MyApp;

subtest 'throws when no app_class' => sub {
    like exception { _build_i18n(app_class => undef) }, qr/app_class required/;
};

subtest 'throws when no locale_dir' => sub {
    like exception { _build_i18n(locale_dir => undef) },
      qr/locale_dir required/;
};

subtest 'throws when cannot open locale_dir' => sub {
    like exception { _build_i18n(locale_dir => 't/i18n_t/unknown_dir/') },
      qr/Can't opendir/;
};

subtest 'returns default langauge' => sub {
    my $i18n = _build_i18n();

    is $i18n->default_language, 'en';
};

subtest 'returns specified languages' => sub {
    my $i18n = _build_i18n(languages => [qw/de uk/]);

    is_deeply [$i18n->languages], [qw/de uk/];
};

subtest 'returns overwritten language' => sub {
    my $i18n = _build_i18n(default_language => 'ru');

    is $i18n->default_language, 'ru';
};

subtest 'detects languages from perl classes' => sub {
    my $i18n = _build_i18n();

    is_deeply [$i18n->languages], [qw/en ru/];
};

subtest 'detects languages from locale classes' => sub {
    my $i18n = _build_i18n(lexicon => 'gettext', locale_dir => 't/i18n_t/locale');

    is_deeply([$i18n->languages], [qw/en ru/]);
};

subtest 'defaults to default language on uknown language' => sub {
    my $i18n = _build_i18n();

    is($i18n->handle('de')->maketext('Hello'), 'Hello');
};

subtest 'defaults to default language on uknown translation' => sub {
    my $i18n = _build_i18n();

    is($i18n->handle('ru')->maketext('Hi'), 'Hi');
};

subtest 'returns handle' => sub {
    my $i18n = _build_i18n();

    my $handle = $i18n->handle('ru');

    is($handle->maketext('Hello'), 'Привет');
};

subtest 'caches handle' => sub {
    my $i18n = _build_i18n();

    my $ref = $i18n->handle('ru');
    my $new_ref = $i18n->handle('ru');

    is $ref, $new_ref;
};

subtest 'throws on unknown handle' => sub {
    my $i18n = _build_i18n();

    $i18n->handle('foo');

    ok 1;
};

sub _build_i18n {
    Turnaround::I18N->new(
        app_class  => 'I18NTest::MyApp',
        locale_dir => 't/i18n_t/I18NTest/MyApp/I18N/',
        @_
    );
}

done_testing;
