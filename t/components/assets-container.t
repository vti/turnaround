use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Turnaround::AssetsContainer;

subtest 'include_js' => sub {
    my $assets = _build_assets();

    $assets->require('/foo.js');

    is($assets->include,
        '<script src="/foo.js" type="text/javascript"></script>');
};

subtest 'include_css' => sub {
    my $assets = _build_assets();

    $assets->require('/foo.css');

    is($assets->include,
'<link rel="stylesheet" href="/foo.css" type="text/css" media="screen" />'
    );
};

subtest 'not_add_the_same_path' => sub {
    my $assets = _build_assets();

    $assets->require('/foo.js');
    $assets->require('/foo.js');

    is($assets->include,
        '<script src="/foo.js" type="text/javascript"></script>');
};

sub _build_assets {
    return Turnaround::AssetsContainer->new(@_);
}

done_testing;
