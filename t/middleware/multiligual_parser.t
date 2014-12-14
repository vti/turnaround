use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Turnaround::Middleware::MultilingualParser;

subtest 'throws when no default_language' => sub {
    like exception { _build_middleware(default_language => undef) },
      qr/default_language required/;
};

subtest 'throws when no languages' => sub {
    like exception { _build_middleware(languages => undef) },
      qr/languages required/;
};

subtest 'parses nothing when no content-type' => sub {
    my $mw = _build_middleware(
        headers => ['Content-Type' => undef],
        body    => '<t><en>English</en><de>Deutsch</de></t>'
    );

    my $env = {'turnaround.language' => 'en'};

    my $res = $mw->call($env);

    like $res->[2]->[0], qr/<t>/;
};

subtest 'parses nothing when content-type not html' => sub {
    my $mw = _build_middleware(
        headers => ['Content-Type' => 'text/plain'],
        body    => '<t><en>English</en><de>Deutsch</de></t>'
    );

    my $env = {'turnaround.language' => 'en'};

    my $res = $mw->call($env);

    like $res->[2]->[0], qr/<t>/;
};

subtest 'parses nothing when no language' => sub {
    my $mw =
      _build_middleware(body => '<t><en>English</en><de>Deutsch</de></t>');

    my $env = {};

    my $res = $mw->call($env);

    like $res->[2]->[0], qr/<t>/;
};

subtest 'parses tag' => sub {
    my $mw =
      _build_middleware(body => '<t><en>English</en><de>Deutsch</de></t>');

    my $env = {'turnaround.language' => 'en'};

    my $res = $mw->call($env);

    is $res->[2]->[0], 'English';
    is $res->[1]->[3], 7;
};

subtest 'parses second tag' => sub {
    my $mw =
      _build_middleware(body => '<t><en>English</en><de>Deutsch</de></t>');

    my $env = {'turnaround.language' => 'de'};

    my $res = $mw->call($env);

    is $res->[2]->[0], 'Deutsch';
    is $res->[1]->[3], 7;
};

sub _build_middleware {
    my (%params) = @_;

    my @headers =
      $params{headers} ? @{$params{headers}} : ('Content-Type' => 'text/html');

    return Turnaround::Middleware::MultilingualParser->new(
        default_language => 'en',
        languages        => [qw/en ru/],
        app              => sub { [200, [@headers], [delete $params{body}]] },
        %params
    );
}

done_testing;
