package Lamework::Middleware::I18N;

use strict;
use warnings;

use base 'Lamework::Middleware::LanguageDetection';

sub new {
    my $class = shift;
    my (%params) = @_;

    die 'i18n is required' unless my $i18n = delete $params{i18n};

    $params{default_language} = $i18n->get_default_language;
    $params{languages}        = [$i18n->get_languages];

    return $class->SUPER::new(%params);
}

sub call {
    my $self = shift;
    my ($env) = @_;

    my $app = $self->SUPER::call(@_);

    my $language = $env->{'lamework.i18n.language'};
    $env->{'lamework.i18n.maketext'} = $self->{i18n}->handle($language);

    return $app;
}

1;
