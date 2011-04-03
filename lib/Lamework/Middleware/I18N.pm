package Lamework::Middleware::I18N;

use strict;
use warnings;

use base 'Lamework::Middleware';

use Encode                 ();
use I18N::LangTags         ();
use I18N::LangTags::Detect ();

sub new {
    my $self = shift->SUPER::new(@_);

    die 'Namespace is required' unless $self->{namespace};

    $self->{default_language} ||= 'en';

    my $re = join '|' => $self->available_languages;
    $self->{language_re} = qr{^/($re)(?=/|$)};

    my $namespace = $self->{namespace};

    eval <<"";
        package $namespace\::I18N;
        use base 'Locale::Maketext';
        1;

    die $@ if $@;

    return $self;
}

sub call {
    my $self = shift;
    my ($env) = @_;

    my @languages;

    my $re = $self->{language_re};
    if ($env->{PATH_INFO} =~ s{$re}{}) {
        $env->{PATH_INFO} = '/' if $env->{PATH_INFO} eq '';
        @languages = ($1);
    }
    else {
        @languages = I18N::LangTags::implicate_supers(
            I18N::LangTags::Detect->http_accept_langs(
                $env->{HTTP_ACCEPT_LANGUAGE}
            )
        );
    }

    push @languages, $self->{default_language};

    my $namespace = $self->{namespace};
    my $class     = "$namespace\::I18N";
    my $handle    = $class->get_handle(@languages);
    $handle->fail_with(sub { $_[1] });

    $env->{'lamework.i18n.language'}  = $handle->language_tag;
    $env->{'lamework.i18n.languages'} = [$self->available_languages];
    $env->{'lamework.i18n.maketext'}  = sub {
        return Encode::decode_utf8($handle->maketext(@_));
    };

    $env->{SCRIPT_NAME} =
      ($env->{SCRIPT_NAME} || '') . '/' . $handle->language_tag;

    return $self->app->($env);
}

sub available_languages {
    my $self = shift;

    my @languages = @{$self->{languages} || []};
    return @languages if @languages;

    return $self->detect_languages;
}

sub detect_languages {
    my $self = shift;

    my $namespace = $self->{namespace};

    my $path  = $INC{"$namespace\.pm"};
    die "Can't detect available languages" unless $path && -f $path;
    $path =~ s{\.pm$}{/I18N};

    die "Can't detect available languages" unless $path && -d $path;

    opendir(my $dh, $path) or die "Can't opendir $path: $!";
    my @files = grep { /\.pm$/ && -f "$path/$_" } readdir($dh);
    closedir $dh;

    @files = map { s{\.pm$}{}; $_ } @files;

    return @files;
}

1;
