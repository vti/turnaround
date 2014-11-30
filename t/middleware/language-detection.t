use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Turnaround::Middleware::LanguageDetection;

subtest 'detect_from_session' => sub {
    my $mw = _build_middleware(default_language => 'en', languages => ['ru']);

    my $env = {
        PATH_INFO       => '',
        'psgix.session' => {'turnaround.i18n.language' => 'ru'}
    };

    $mw->call($env);

    is($env->{'turnaround.i18n.language'}, 'ru');
};

subtest 'add_human_readable_name' => sub {
    my $mw = _build_middleware(default_language => 'en', languages => ['ru']);

    my $env = {
        PATH_INFO       => '',
        'psgix.session' => {'turnaround.i18n.language' => 'ru'}
    };

    $mw->call($env);

    is($env->{'turnaround.i18n.language_name'}, 'Russian');
};

subtest 'detect_from_custom_cb' => sub {
    my $mw = _build_middleware(
        default_language => 'en',
        languages        => [qw/ru en/],
        custom_cb        => sub { 'en' }
    );

    my $env = {PATH_INFO => '/ru/'};

    $mw->call($env);

    is($env->{'turnaround.i18n.language'}, 'en');
};

subtest 'detect_from_path' => sub {
    my $mw = _build_middleware(default_language => 'en', languages => ['ru']);

    my $env = {PATH_INFO => '/ru/'};

    $mw->call($env);

    is($env->{'turnaround.i18n.language'}, 'ru');
};

subtest 'modify_path' => sub {
    my $mw = _build_middleware(default_language => 'en', languages => ['ru']);

    my $env = {PATH_INFO => '/ru/hello'};

    $mw->call($env);

    is($env->{PATH_INFO}, '/hello');
};

subtest 'detect_from_headers' => sub {
    my $mw = _build_middleware(default_language => 'en', languages => ['ru']);

    my $env = {PATH_INFO => '', HTTP_ACCEPT_LANGUAGE => 'ru'};

    $mw->call($env);

    is($env->{'turnaround.i18n.language'}, 'ru');
};

subtest 'set_default_language_when_unknown_detected' => sub {
    my $mw = _build_middleware(default_language => 'en', languages => ['ru']);

    my $env = {
        PATH_INFO       => '',
        'psgix.session' => {'turnaround.i18n.language' => 'es'}
    };

    $mw->call($env);

    is($env->{'turnaround.i18n.language'}, 'en');
};

subtest 'set_default_language_when_not_detected' => sub {
    my $mw = _build_middleware(default_language => 'en', languages => ['ru']);

    my $env = {PATH_INFO => ''};

    $mw->call($env);

    is($env->{'turnaround.i18n.language'}, 'en');
};

subtest 'save_to_session' => sub {
    my $mw = _build_middleware(default_language => 'en', languages => ['ru']);

    my $env = {PATH_INFO => '/ru/'};

    $mw->call($env);

    is($env->{'psgix.session'}->{'turnaround.i18n.language'}, 'ru');
};

sub _build_middleware {
    return Turnaround::Middleware::LanguageDetection->new(
        app => sub { [200, [], ['OK']] },
        @_
    );
}

done_testing;
