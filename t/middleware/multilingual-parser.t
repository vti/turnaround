use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Turnaround::Middleware::MultilingualParser;

subtest 'parse_tag' => sub {
    my $mw = _build_middleware('<t><en>English</en><de>Deutsch</de></t>');

    my $env = {'turnaround.language' => 'en'};

    my $res = $mw->call($env);

    is($res->[2]->[0], 'English');
    is($res->[1]->[3], 7);
};

subtest 'parse_second_tag' => sub {
    my $mw = _build_middleware('<t><en>English</en><de>Deutsch</de></t>');

    my $env = {'turnaround.language' => 'de'};

    my $res = $mw->call($env);

    is($res->[2]->[0], 'Deutsch');
    is($res->[1]->[3], 7);
};

sub _build_middleware {
    my ($body) = shift;

    return Turnaround::Middleware::MultilingualParser->new(
        default_language => 'en',
        languages        => [qw/en ru/],
        app => sub { [200, ['Content-Type' => 'text/html'], [$body]] },
        @_
    );
}

done_testing;
