use strict;
use warnings;

use Test::More;
use Test::Requires;
use Test::Fatal;

BEGIN { test_requires 'I18N::AcceptLanguage' }

use Turnaround::Middleware::LanguageDetection;

subtest 'throws when no language' => sub {
    like exception { _build_middleware(default_language => undef) },
      qr/default_language required/;
};

subtest 'throws when languages' => sub {
    like exception {
        _build_middleware(languages => undef)
    }, qr/languages required/;
};

subtest 'detects from session' => sub {
    my $mw = _build_middleware();

    my $env = {
        PATH_INFO       => '',
        'psgix.session' => {'turnaround.i18n.language' => 'ru'}
    };

    $mw->call($env);

    is($env->{'turnaround.i18n.language'}, 'ru');
};

subtest 'does not detect from session when off' => sub {
    my $mw = _build_middleware(use_session => 0);

    my $env = {
        PATH_INFO       => '',
        'psgix.session' => {'turnaround.i18n.language' => 'ru'}
    };

    $mw->call($env);

    is $env->{'turnaround.i18n.language'}, 'en';
};

subtest 'adds human readable name' => sub {
    my $mw = _build_middleware();

    my $env = {
        PATH_INFO       => '',
        'psgix.session' => {'turnaround.i18n.language' => 'ru'}
    };

    $mw->call($env);

    is $env->{'turnaround.i18n.language_name'}, 'Russian';
};

subtest 'detects from custom cb' => sub {
    my $mw = _build_middleware(
        languages => [qw/ru en/],
        custom_cb => sub { 'en' }
    );

    my $env = {PATH_INFO => '/ru/'};

    $mw->call($env);

    is $env->{'turnaround.i18n.language'}, 'en';
};

subtest 'defaults when cannot detect from custom_cb' => sub {
    my $mw = _build_middleware(
        languages => [qw/ru en/],
        custom_cb => sub { }
    );

    my $env = {PATH_INFO => ''};

    $mw->call($env);

    is $env->{'turnaround.i18n.language'}, 'en';
};

subtest 'detects from path' => sub {
    my $mw = _build_middleware();

    my $env = {PATH_INFO => '/ru/'};

    $mw->call($env);

    is $env->{'turnaround.i18n.language'}, 'ru';
};

subtest 'does not detect from path when off' => sub {
    my $mw = _build_middleware(use_path => 0);

    my $env = {PATH_INFO => '/ru/'};

    $mw->call($env);

    is $env->{'turnaround.i18n.language'}, 'en';
};

subtest 'modifies path' => sub {
    my $mw = _build_middleware();

    my $env = {PATH_INFO => '/ru/hello'};

    $mw->call($env);

    is $env->{PATH_INFO}, '/hello';
};

subtest 'detects from headers' => sub {
    my $mw = _build_middleware();

    my $env = {PATH_INFO => '', HTTP_ACCEPT_LANGUAGE => 'ru'};

    $mw->call($env);

    is $env->{'turnaround.i18n.language'}, 'ru';
};

subtest 'does not detect from headers when off' => sub {
    my $mw = _build_middleware(use_header => 0);

    my $env = {PATH_INFO => '', HTTP_ACCEPT_LANGUAGE => 'ru'};

    $mw->call($env);

    is $env->{'turnaround.i18n.language'}, 'en';
};

subtest 'set_default_language_when_unknown_detected' => sub {
    my $mw = _build_middleware();

    my $env = {
        PATH_INFO       => '',
        'psgix.session' => {'turnaround.i18n.language' => 'es'}
    };

    $mw->call($env);

    is($env->{'turnaround.i18n.language'}, 'en');
};

subtest 'set_default_language_when_not_detected' => sub {
    my $mw = _build_middleware();

    my $env = {PATH_INFO => ''};

    $mw->call($env);

    is($env->{'turnaround.i18n.language'}, 'en');
};

subtest 'save_to_session' => sub {
    my $mw = _build_middleware();

    my $env = {PATH_INFO => '/ru/'};

    $mw->call($env);

    is($env->{'psgix.session'}->{'turnaround.i18n.language'}, 'ru');
};

sub _build_middleware {
    return Turnaround::Middleware::LanguageDetection->new(
        app => sub { [200, [], ['OK']] },
        default_language => 'en',
        languages        => ['ru'],
        @_
    );
}

done_testing;
