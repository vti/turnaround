use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Turnaround::Home;

subtest 'builds home from path' => sub {
    my $home = _build_home(path => '/foo/bar');

    is $home => '/foo/bar';
};

subtest 'detect from loaded app_class' => sub {
    my $home = _build_home(app_class => 'Turnaround::Home');

    like $home, qr{/lib$};
};

subtest 'defaults to current dir when unknown app_class' => sub {
    my $home = _build_home(app_class => 'UnlikelyToBeKnownClass');

    is $home, '.';
};

subtest 'returns true in bool context' => sub {
    my $home = _build_home(path => '/foo/bar');

    ok $home;
};

subtest 'throws when cannot detect home' => sub {
    like exception { _build_home() }, qr/cannot detect home, pass it manually/;
};

subtest 'implements catfile' => sub {
    my $home = _build_home(path => '/foo/bar');

    is $home->catfile('hello', 'there'),
      File::Spec->catfile('/foo/bar/hello/there');
};

sub _build_home { Turnaround::Home->new(@_) }

done_testing;
