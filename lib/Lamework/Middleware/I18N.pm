package Lamework::Middleware::I18N;

use strict;
use warnings;

use base 'Lamework::Middleware';

use I18N::AcceptLanguage;

sub new {
    my $self = shift->SUPER::new(@_);

    $self->{default_language} ||= 'en';

    $self->{languages} = [$self->{languages}]
      unless ref $self->{languages} eq 'ARRAY';

    my $re = join '|' => @{$self->{languages}};
    $self->{language_re} = qr{^/($re)(?=/|$)};

    return $self;
}

sub call {
    my $self = shift;
    my ($env) = @_;

    my $languages = $self->{languages};

    my $language;

    my $re = $self->{language_re};
    if ($env->{PATH_INFO} =~ s{$re}{}) {
        $env->{PATH_INFO} = '/' if $env->{PATH_INFO} eq '';
        $language = $1;
    }
    else {
        $language =
          $self->acceptor->accepts($env->{HTTP_ACCEPT_LANGUAGE}, $languages);

        $language ||= $self->{default_language};
    }

    $env->{SCRIPT_NAME} = $env->{SCRIPT_NAME} . '/' . $language;

    $env->{'lamework.i18n.language'} = $language;

    return $self->app->($env);
}

sub acceptor {
    my $self = shift;

    $self->{acceptor} ||= I18N::AcceptLanguage->new;

    return $self->{acceptor};

}

1;
