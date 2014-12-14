package Turnaround::I18N;

use strict;
use warnings;

use Carp qw(croak);
use List::Util qw(first);
use Locale::Maketext;
use Turnaround::Loader;
use Turnaround::I18N::Handle;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{locale_dir} = $params{locale_dir} || croak 'locale_dir required';
    $self->{lexicon}    = $params{lexicon}    || 'perl';

    $self->{app_class} = $params{app_class} || croak 'app_class required';
    $self->{loader}    = $params{loader}    || Turnaround::Loader->new;
    $self->{default_language} = $params{default_language} || 'en';
    $self->{languages} =
      $params{languages} || [sort $self->_detect_languages()];

    $self->_init_lexicon;

    return $self;
}

sub default_language {
    my $self = shift;
    my ($default_language) = @_;

    return $self->{default_language};
}

sub languages {
    my $self = shift;

    return @{$self->{languages}};
}

sub handle {
    my $self = shift;
    my ($language) = @_;

    my $class = "$self->{app_class}\::I18N";

    $self->{handles}->{$language} ||= do {
        my $handle = $class->get_handle($language);
        $handle->fail_with(sub { $_[1] });

        Turnaround::I18N::Handle->new(handle => $handle, language => $language);
    };

    return $self->{handles}->{$language};
}

sub _init_lexicon {
    my $self = shift;

    if ($self->{lexicon} eq 'perl') {
        my $app_class = $self->{app_class};

        my $i18n_class = "$app_class\::I18N";
        if (!$self->{loader}->try_load_class($i18n_class)) {
            eval <<"EOC" or croak $@;
                package $i18n_class;
                use base 'Locale::Maketext';
                sub _loaded {1}
                1;
EOC
        }

        my $default_i18n_class = "$i18n_class\::$self->{default_language}";
        if (!$self->{loader}->try_load_class($default_i18n_class)) {
            eval <<"EOC" or croak $@;
                package $default_i18n_class;
                use base '$i18n_class';
                our %Lexicon = (_AUTO => 1);
                sub _loaded {1}
                1;
EOC
        }
    }
    elsif ($self->{lexicon} eq 'gettext') {
        eval <<"EOC" || croak $@;
            package $self->{app_class}::I18N;
            use base 'Locale::Maketext';
            use Locale::Maketext::Lexicon {
                '*'      => [Gettext => "$self->{locale_dir}/*.po"],
                _auto    => 1,
                _decode  => 1,
                _preload => 1
            };
            1;
EOC
    }

    return $self;
}

sub _detect_languages {
    my $self = shift;

    my $path = $self->{locale_dir};

    opendir(my $dh, $path) or croak "Can't opendir $path: $!";
    my @files = grep { /\.p[om]$/ && -e "$path/$_" } readdir($dh);
    closedir $dh;

    my @languages = @files;
    s{\.p[om]$}{} for @languages;

    unshift @languages, $self->{default_language}
      unless first { $_ eq $self->{default_language} } @languages;

    return @languages;
}

1;
