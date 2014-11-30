use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Turnaround::Home;

subtest 'build_home_from_path' => sub {
    my $home = _build_home(path => '/foo/bar');

    is($home => '/foo/bar');
};

subtest 'implement_catfile' => sub {
    my $home = _build_home(path => '/foo/bar');

    is($home->catfile('hello', 'there') =>
          File::Spec->catfile('/foo/bar/hello/there'));
};

sub _build_home {
    return Turnaround::Home->new(@_);
}

done_testing;
