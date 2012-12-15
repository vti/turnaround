package HomeTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Turnaround::Home;

sub build_home_from_path : Test {
    my $self = shift;

    my $home = $self->_build_home(path => '/foo/bar');

    is($home => '/foo/bar');
}

sub implement_catfile : Test {
    my $self = shift;

    my $home = $self->_build_home(path => '/foo/bar');

    is($home->catfile('hello', 'there') =>
          File::Spec->catfile('/foo/bar/hello/there'));
}

sub _build_home {
    my $self = shift;

    return Turnaround::Home->new(@_);
}

1;
