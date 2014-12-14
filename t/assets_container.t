use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Turnaround::AssetsContainer;

subtest 'requires js' => sub {
    my $assets = _build_assets();

    $assets->require('/foo.js');

    is($assets->include,
        '<script src="/foo.js" type="text/javascript"></script>');
};

subtest 'requires with specified type' => sub {
    my $assets = _build_assets();

    $assets->require('/foo.bar', 'js');

    is($assets->include,
        '<script src="/foo.bar" type="text/javascript"></script>');
};

subtest 'requires css' => sub {
    my $assets = _build_assets();

    $assets->require('/foo.css');

    is($assets->include,
'<link rel="stylesheet" href="/foo.css" type="text/css" media="screen" />'
    );
};

subtest 'does not add same requires' => sub {
    my $assets = _build_assets();

    $assets->require('/foo.js');
    $assets->require('/foo.js');

    is($assets->include,
        '<script src="/foo.js" type="text/javascript"></script>');
};

subtest 'includes only specified type' => sub {
    my $assets = _build_assets();

    $assets->require('/foo.js');
    $assets->require('/foo.css');

    is($assets->include(type => 'js'),
        '<script src="/foo.js" type="text/javascript"></script>');
};

subtest 'throws when unknown type' => sub {
    my $assets = _build_assets();

    $assets->require('/foo.foo');

    like exception { $assets->include },
      qr/unknown asset type 'foo'/;
};

sub _build_assets {
    return Turnaround::AssetsContainer->new(@_);
}

done_testing;
