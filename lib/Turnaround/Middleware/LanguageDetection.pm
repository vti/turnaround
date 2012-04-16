package Turnaround::Middleware::LanguageDetection;

use strict;
use warnings;

use base 'Turnaround::Middleware';

use I18N::AcceptLanguage;
use I18N::LangTags::List ();

sub new {
    my $self = shift->SUPER::new(@_);

    die 'default_language is required' unless $self->{default_language};
    die 'languages is required'        unless $self->{languages};

    $self->{name_prefix} = 'turnaround.i18n.';

    $self->{use_path}    = 1 unless defined $self->{use_path};
    $self->{use_session} = 1 unless defined $self->{use_session};
    $self->{use_header}  = 1 unless defined $self->{use_header};

    return $self;
}

sub call {
    my $self = shift;
    my ($env) = @_;

    $self->_detect_language($env);

    return $self->app->($env);
}

sub _detect_language {
    my $self = shift;
    my ($env) = @_;

    my $lang;

    $lang ||= $self->_detect_from_path($env)    if $self->{use_path};
    $lang ||= $self->_detect_from_session($env) if $self->{use_session};
    $lang ||= $self->_detect_from_header($env)  if $self->{use_header};

    if (!$lang || !$self->_is_allowed($lang)) {
        $lang = $self->{default_language};
    }

    $env->{$self->{name_prefix} . 'language'} = $lang;
    $env->{$self->{name_prefix} . 'language_name'} = I18N::LangTags::List::name($lang);

    if ($self->{use_session}) {
        $env->{'psgix.session'}->{$self->{name_prefix} . 'language'} = $lang;
    }
}

sub _detect_from_session {
    my $self = shift;
    my ($env) = @_;

    return unless my $session = $env->{'psgix.session'};

    return $session->{$self->{name_prefix} . 'language'};
}

sub _detect_from_path {
    my $self = shift;
    my ($env) = @_;

    my $path = $env->{PATH_INFO};

    my $languages_re = join '|', @{$self->{languages}};
    if ($path =~ s{^/($languages_re)(?=/|$)}{}) {
        $env->{PATH_INFO} = $path;
        return $1;
    }

    return;
}

sub _detect_from_header {
    my $self = shift;
    my ($env) = @_;

    return unless my $accept_header = $env->{HTTP_ACCEPT_LANGUAGE};

    return $self->_build_acceptor->accepts($accept_header,
        $self->{languages});
}

sub _build_acceptor {
    my $self = shift;

    return I18N::AcceptLanguage->new();
}

sub _is_allowed {
    my $self = shift;
    my ($lang) = @_;

    return !!grep { $lang eq $_ } $self->{default_language},
      @{$self->{languages}};
}

1;
