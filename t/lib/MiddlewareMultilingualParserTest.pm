package MiddlewareMultilingualParserTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Lamework::Middleware::MultilingualParser;

sub parse_tag : Test(2) {
    my $self = shift;

    my $mw =
      $self->_build_middleware('<t><en>English</en><de>Deutsch</de></t>');

    my $env = {'lamework.language' => 'en'};

    my $res = $mw->call($env);

    is($res->[2]->[0], 'English');
    is($res->[1]->[3], 7);
}

sub parse_second_tag : Test(2) {
    my $self = shift;

    my $mw =
      $self->_build_middleware('<t><en>English</en><de>Deutsch</de></t>');

    my $env = {'lamework.language' => 'de'};

    my $res = $mw->call($env);

    is($res->[2]->[0], 'Deutsch');
    is($res->[1]->[3], 7);
}

sub _build_middleware {
    my $self = shift;
    my ($body) = shift;

    return Lamework::Middleware::MultilingualParser->new(
        default_language => 'en',
        languages        => [qw/en ru/],
        app => sub { [200, ['Content-Type' => 'text/html'], [$body]] },
        @_
    );
}

1;
