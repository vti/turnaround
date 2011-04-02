#!/usr/bin/env perl

use 5.008007;

use strict;
use warnings;

use ExtUtils::MakeMaker;

my ($mm) = $ExtUtils::MakeMaker::VERSION =~ /^([^_]+)/;

WriteMakefile(
    NAME         => 'Lamework',
    VERSION_FROM => 'lib/Lamework.pm',
    ABSTRACT     => 'Lamework',
    AUTHOR       => 'Viacheslav Tykhanovskyi <vti@cpan.org>',

    ($mm < 6.3002 ? () : ('LICENSE' => 'artistic_2')),

    (   $mm < 6.46
        ? ()
        : ( META_MERGE => {
                requires  => {perl => '5.008007'},
                resources => {
                    license    => 'http://dev.perl.org/licenses/',
                    repository => 'http://github.com/vti/lamework'
                },
                no_index => {directory => [qw/t/]}
            },
            META_ADD => {
                build_requires     => {},
                configure_requires => {}
            },
        )
    ),

    PREREQ_PM => {
        'Carp'                   => '0',
        'Class::Load'            => '0',
        'Config::Tiny'           => '0',
        'Cwd'                    => '0',
        'Encode'                 => '0',
        'File::Basename'         => '0',
        'File::Spec'             => '0',
        'I18N::LangTags'         => '0',
        'I18N::LangTags::Detect' => '0',
        'Plack'                  => '0',
        'Routes::Tiny'           => '0',
        'Scalar::Util'           => '0',
        'String::CamelCase'      => '0',
        'Text::Caml'             => '0',
        'Try::Tiny'              => '0',
    },
    test => {TESTS => 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t'}
);
