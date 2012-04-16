package MiddlewareLanguageDetectionTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Turnaround::Middleware::LanguageDetection;

sub detect_from_session : Test {
    my $self = shift;

    my $mw =
      $self->_build_middleware(default_language => 'en', languages => ['ru']);

    my $env = {PATH_INFO => '', 'psgix.session' => {'lamework.i18n.language' => 'ru'}};

    $mw->call($env);

    is($env->{'lamework.i18n.language'}, 'ru');
}

sub add_human_readable_name : Test {
    my $self = shift;

    my $mw =
      $self->_build_middleware(default_language => 'en', languages => ['ru']);

    my $env = {PATH_INFO => '', 'psgix.session' => {'lamework.i18n.language' => 'ru'}};

    $mw->call($env);

    is($env->{'lamework.i18n.language_name'}, 'Russian');
}

sub detect_from_path : Test {
    my $self = shift;

    my $mw =
      $self->_build_middleware(default_language => 'en', languages => ['ru']);

    my $env = {PATH_INFO => '/ru/'};

    $mw->call($env);

    is($env->{'lamework.i18n.language'}, 'ru');
}

sub modify_path : Test {
    my $self = shift;

    my $mw =
      $self->_build_middleware(default_language => 'en', languages => ['ru']);

    my $env = {PATH_INFO => '/ru/hello'};

    $mw->call($env);

    is($env->{PATH_INFO}, '/hello');
}

sub detect_from_headers : Test {
    my $self = shift;

    my $mw =
      $self->_build_middleware(default_language => 'en', languages => ['ru']);

    my $env = {PATH_INFO => '', HTTP_ACCEPT_LANGUAGE => 'ru'};

    $mw->call($env);

    is($env->{'lamework.i18n.language'}, 'ru');
}

sub set_default_language_when_unknown_detected : Test {
    my $self = shift;

    my $mw =
      $self->_build_middleware(default_language => 'en', languages => ['ru']);

    my $env = {PATH_INFO => '', 'psgix.session' => {'lamework.i18n.language' => 'es'}};

    $mw->call($env);

    is($env->{'lamework.i18n.language'}, 'en');
}

sub set_default_language_when_not_detected : Test {
    my $self = shift;

    my $mw =
      $self->_build_middleware(default_language => 'en', languages => ['ru']);

    my $env = {PATH_INFO => ''};

    $mw->call($env);

    is($env->{'lamework.i18n.language'}, 'en');
}

sub save_to_session : Test {
    my $self = shift;

    my $mw =
      $self->_build_middleware(default_language => 'en', languages => ['ru']);

    my $env = {PATH_INFO => '/ru/'};

    $mw->call($env);

    is($env->{'psgix.session'}->{'lamework.i18n.language'}, 'ru');
}

sub _build_middleware {
    my $self = shift;

    return Turnaround::Middleware::LanguageDetection->new(
        app => sub { [200, [], ['OK']] },
        @_
    );
}

1;
