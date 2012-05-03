package AssetsContainerTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Turnaround::AssetsContainer;

sub include_js : Test {
    my $self = shift;

    my $assets = $self->_build_assets;

    $assets->require('/foo.js');

    is($assets->include, '<script src="/foo.js" type="text/javascript"></script>');
}

sub not_add_the_same_path : Test {
    my $self = shift;

    my $assets = $self->_build_assets;

    $assets->require('/foo.js');
    $assets->require('/foo.js');

    is($assets->include, '<script src="/foo.js" type="text/javascript"></script>');
}

sub _build_assets {
    my $self = shift;

    return Turnaround::AssetsContainer->new(@_);
}

1;
