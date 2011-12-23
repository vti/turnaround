#!/usr/bin/env perl

use strict;
use warnings;

use inc::Module::Install;

name 'Lamework';

version_from 'lib/Lamework.pm';
author 'Viacheslav Tykhanovskyi <vti@cpan.org>';
abstract 'Lamework';
license 'artistic_2';
perl_version '5.008007';

requires 'Carp'              => '0';
requires 'Cwd'               => '0';
requires 'Encode'            => '0';
requires 'File::Basename'    => '0';
requires 'File::Spec'        => '0';
requires 'Scalar::Util'      => '0';

requires 'Config::Tiny'      => '0';
requires 'Plack'             => '0';
requires 'Routes::Tiny'      => '0';
requires 'String::CamelCase' => '0';
requires 'Text::Caml'        => '0';
requires 'Try::Tiny'         => '0';

test_requires 'Test::Class' => '0';
test_requires 'Test::Fatal' => '0';
test_requires 'Test::More'  => '0';
test_requires 'Test::Spec'  => '0';

tests 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t';

no_index directory => 't';

resources
  bugtracker => 'http://github.com/vti/lamework/issues',
  repository => 'http://github.com/vti/lamework/',
  license    => 'http://dev.perl.org/licenses/';

auto_install;

WriteAll;
