use strict;
use warnings;
use utf8;

use lib 't/components';

use Test::More;
use Test::Fatal;

use Turnaround::I18N;

use I18NTest::MyApp;

subtest 'detect_languages' => sub {
    my $i18n = _build_i18n();

    is_deeply([$i18n->get_languages], [qw/en ru/]);
};

subtest 'detect_languages_names' => sub {
    my $i18n = _build_i18n();

    is_deeply($i18n->get_languages_names, {en => 'English', ru => 'Russian'});
};

subtest 'default_to_default_language_on_uknown_language' => sub {
    my $i18n = _build_i18n();

    is($i18n->handle('de')->maketext('Hello'), 'Hello');
};

subtest 'default_to_default_language_on_uknown_translation' => sub {
    my $i18n = _build_i18n();

    is($i18n->handle('ru')->maketext('Hi'), 'Hi');
};

subtest 'return_handle' => sub {
    my $i18n = _build_i18n();

    my $handle = $i18n->handle('ru');

    is($handle->maketext('Hello'), 'Привет');
};

sub _build_i18n {
    return Turnaround::I18N->new(app_class => 'I18NTest::MyApp', @_);
}

done_testing;
