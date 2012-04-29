#!/usr/bin/env perl

use 5.008007;

use strict;
use warnings;

use ExtUtils::MakeMaker;

my ($mm) = $ExtUtils::MakeMaker::VERSION =~ /^([^_]+)/;

WriteMakefile(
    NAME          => 'Turnaround',
    VERSION_FROM  => 'lib/Turnaround.pm',
    ABSTRACT_FROM => 'lib/Turnaround.pm',
    AUTHOR        => 'Viacheslav Tykhanovskyi <vti@cpan.org>',

    ($mm < 6.3002 ? () : ('LICENSE' => 'artistic_2')),

    (   $mm < 6.46
        ? ()
        : ( META_MERGE => {
                requires  => {perl => '5.008007'},
                resources => {
                    license    => 'http://dev.perl.org/licenses/',
                    repository => 'http://github.com/vti/turnaround'
                },
                no_index => {directory => [qw/t/]}
            }
        )
    ),

    PREREQ_PM => {
        'Carp'             => '0',
        'Cwd'              => '0',
        'Encode'           => '0',
        'Exporter'         => '0',
        'File::Basename'   => '0',
        'File::Spec'       => '0',
        'List::Util'       => '0',
        'Locale::Maketext' => '0',
        'Scalar::Util'     => '0',
        'Storable'         => '0',

        'Config::Tiny'         => '0',
        'I18N::AcceptLanguage' => '0',
        'I18N::LangTags::List' => '0',
        'Plack'                => '0',
        'Routes::Tiny'         => '0',
        'String::CamelCase'    => '0',
        'Text::Caml'           => '0',
        'YAML::Tiny'           => '0',
        'MIME::Lite'           => '0',

        'Test::Class' => '0',
        'Test::Fatal' => '0',
        'Test::More'  => '0',
    },
    dist  => {COMPRESS => 'gzip -9f', SUFFIX => 'gz'},
    clean => {FILES    => 'Turnaround-*'},
    test  => {TESTS    => 't/*.t t/*/*.t'}
);
