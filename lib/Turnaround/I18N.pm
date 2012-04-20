package Turnaround::I18N;

use strict;
use warnings;

use base 'Turnaround::Base';

use I18N::LangTags::List ();
use Locale::Maketext;
use Turnaround::Loader;
use Turnaround::I18N::Handle;

sub BUILD {
    my $self = shift;

    die 'app_class is required' unless $self->{app_class};

    $self->{loader}           ||= Turnaround::Loader->new;

    $self->{default_language} ||= 'en';
    $self->{languages}        ||= [$self->_detect_languages()];
    $self->{languages_names} ||= {map { $_ => I18N::LangTags::List::name($_) }
          @{$self->{languages}}};

    my $app_class = $self->{app_class};

    my $i18n_class = "$app_class\::I18N";
    if (!$self->{loader}->try_load_class($i18n_class)) {
        eval <<"";
            package $i18n_class;
            use base 'Locale::Maketext';
            sub _loaded {1}
            1;

    }

    my $default_i18n_class = "$i18n_class\::$self->{default_language}";
    if (!$self->{loader}->try_load_class($default_i18n_class)) {
        eval <<"";
            package $default_i18n_class;
            use base '$i18n_class';
            our %Lexicon = (_AUTO => 1);
            sub _loaded {1}
            1;

    }
}

sub set_default_language {
    my $self = shift;
    my ($value) = @_;

    $self->{default_language} = $value;

    return $self;
}

sub get_default_language {
    my $self = shift;
    my ($default_language) = @_;

    return $self->{default_language};
}

sub set_languages {
    my $self = shift;
    my ($value) = @_;

    $self->{languages} = $value;

    return $self;
}

sub get_languages {
    my $self = shift;

    return @{$self->{languages}};
}

sub set_languages_names {
    my $self = shift;
    my ($value) = @_;

    $self->{languages_names} = $value;

    return $self;
}

sub get_languages_names {
    my $self = shift;

    return $self->{languages_names};
}

sub handle {
    my $self = shift;
    my ($language) = @_;

    my $class = "$self->{app_class}\::I18N";

    $self->{handles}->{$language} ||= do {
        my $handle = $class->get_handle($language);
        die qq{Can't get handle for '$language'} unless $handle;
        $handle->fail_with(sub { $_[1] });
        Turnaround::I18N::Handle->new(handle => $handle, language => $language);
    };

    return $self->{handles}->{$language};
}

sub _detect_languages {
    my $self = shift;

    my $app_class = $self->{app_class};
    $app_class =~ s{::}{/}g;

    my $path = $INC{"$app_class\.pm"};
    die "Can't detect available languages" unless $path && -f $path;

    $path =~ s{\.pm$}{/I18N};
    die "Can't detect available languages" unless $path && -d $path;

    opendir(my $dh, $path) or die "Can't opendir $path: $!";
    my @files = grep { /\.p(?:o|m)$/ && -f "$path/$_" } readdir($dh);
    closedir $dh;

    my @languages = map { s{\.p(?:o|m)$}{}; $_ } @files;

    unshift @languages, $self->{default_language}
      unless grep { $_ eq $self->{default_language} } @languages;

    return @languages;
}

1;
