package I18NTest;

use strict;
use warnings;
use utf8;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Turnaround::I18N;

use lib 't/lib/I18NTest';

use I18NTest::MyApp;

sub detect_languages : Test {
    my $self = shift;

    my $i18n = $self->_build_i18n();

    is_deeply([$i18n->get_languages], [qw/en ru/]);
}

sub detect_languages_names : Test {
    my $self = shift;

    my $i18n = $self->_build_i18n();

    is_deeply($i18n->get_languages_names, {en => 'English', ru => 'Russian'});
}

sub default_to_default_language_on_uknown_language : Test {
    my $self = shift;

    my $i18n = $self->_build_i18n();

    is($i18n->handle('de')->maketext('Hello'), 'Hello');
}

sub default_to_default_language_on_uknown_translation : Test {
    my $self = shift;

    my $i18n = $self->_build_i18n();

    is($i18n->handle('ru')->maketext('Hi'), 'Hi');
}

sub return_handle : Test {
    my $self = shift;

    my $i18n = $self->_build_i18n();

    my $handle = $i18n->handle('ru');

    is($handle->maketext('Hello'), 'Привет');
}

sub _build_i18n {
    my $self = shift;

    return Turnaround::I18N->new(app_class => 'I18NTest::MyApp', @_);
}

1;
