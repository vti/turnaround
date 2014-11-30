use strict;
use warnings;

use Test::More;
use Test::Fatal;

use lib 't/core/LoaderTest';

use Turnaround::Loader;

subtest 'know_when_class_is_already_loaded' => sub {
    my $loader = _build_loader();

    ok($loader->is_class_loaded('LoaderTestFoo'));
};

subtest 'load_loaded_class' => sub {
    my $loader = _build_loader();

    is($loader->load_class('LoaderTestFoo'), 'LoaderTestFoo');
};

subtest 'load_existing_class_searching_namespaces' => sub {
    my $loader = _build_loader(namespaces => [qw/Foo:: Bar::/]);

    is($loader->load_class('Class'), 'Bar::Class');
};

subtest 'load_class_by_absolute_name' => sub {
    my $loader = _build_loader();

    is($loader->load_class('+Bar::Class'), 'Bar::Class');
};

subtest 'throw_on_invalid_class_name' => sub {
    my $loader = _build_loader();

    ok(exception { $loader->load_class('@#$@') });
};

subtest 'throw_on_unknown_class' => sub {
    my $loader = _build_loader();

    like exception { $loader->load_class('Unknown') },
      qr/Can't locate Unknown\.pm in \@INC/;
};

subtest 'throw_on_class_with_syntax_errors' => sub {
    my $loader = _build_loader();

    like exception { $loader->load_class('WithSyntaxErrors') },
      qr/Bareword "w" not allowed while "strict subs" in use/;
};

subtest 'is_class_loaded' => sub {
    my $loader = _build_loader();

    ok($loader->is_class_loaded('LoaderTestFoo'));
};

subtest 'not_is_class_loaded' => sub {
    my $loader = _build_loader();

    ok(!$loader->is_class_loaded('Foo123'));
};

sub _build_loader {
    Turnaround::Loader->new(@_);
}

done_testing;

package LoaderTestFoo;
sub bar { }
