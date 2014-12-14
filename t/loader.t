use strict;
use warnings;

use Test::More;
use Test::Fatal;

use lib 't/loader';

use Turnaround::Loader;

subtest 'throws when no class passed' => sub {
    my $loader = _build_loader();

    like exception { $loader->is_class_loaded() }, qr/class name required/;
    like exception { $loader->load_class() },      qr/class name required/;
    like exception { $loader->try_load_class() },  qr/class name required/;
};

subtest 'knows when class is already loaded' => sub {
    my $loader = _build_loader();

    ok $loader->is_class_loaded('LoaderTestFoo');
};

subtest 'returns false when INC but undefined' => sub {
    my $loader = _build_loader();

    local $INC{'Not/Defined.pm'} = undef;
    ok !$loader->is_class_loaded('Not::Defined');
};

subtest 'loads already loaded class' => sub {
    my $loader = _build_loader();

    is $loader->load_class('LoaderTestFoo'), 'LoaderTestFoo';
};

subtest 'loads existing class searching namespaces' => sub {
    my $loader = _build_loader(namespaces => [qw/Foo:: Bar::/]);

    is $loader->load_class('Class'), 'Bar::Class';
};

subtest 'loads class by absolute name' => sub {
    my $loader = _build_loader();

    is $loader->load_class('+Bar::Class'), 'Bar::Class';
};

subtest 'throws on invalid class name' => sub {
    my $loader = _build_loader();

    like exception { $loader->load_class('@#$@') },
      qr/invalid class name 'Foo::@#\$\@'/;
};

subtest 'throws on unknown class' => sub {
    my $loader = _build_loader();

    like exception { $loader->load_class('Unknown') },
      qr/Can't locate Unknown\.pm in \@INC/;
};

subtest 'throws on class with syntax errors' => sub {
    my $loader = _build_loader();

    like exception { $loader->load_class('WithSyntaxErrors') },
      qr/Bareword "w" not allowed while "strict subs" in use/;
};

subtest 'returns false when class not found' => sub {
    my $loader = _build_loader();

    ok !$loader->try_load_class('UnknownClass');
};

subtest 'returns class when class already loaded' => sub {
    my $loader = _build_loader();

    is $loader->try_load_class('LoaderTestFoo'), 'LoaderTestFoo';
};

subtest 'returns class when class found' => sub {
    my $loader = _build_loader();

    is $loader->try_load_class('TryLoadClass'), 'TryLoadClass';
};

subtest 'returns true when class loaded' => sub {
    my $loader = _build_loader();

    ok $loader->is_class_loaded('LoaderTestFoo');
};

subtest 'returns false when class not loaded' => sub {
    my $loader = _build_loader();

    ok !$loader->is_class_loaded('Foo123');
};

sub _build_loader {
    Turnaround::Loader->new(namespaces => [qw/Foo::/], @_);
}

done_testing;

package LoaderTestFoo;
sub bar { }
