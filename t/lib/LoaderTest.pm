package LoaderTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Lamework::Loader;

use lib 't/lib/LoaderTest';

sub load_existing_class : Test {
    my $self = shift;

    my $loader = $self->_build_loader;

    is($loader->load_class('LoaderTest'), 'LoaderTest');
}

sub load_existing_class_searching_namespaces : Test {
    my $self = shift;

    my $loader = $self->_build_loader(namespaces => [qw/Foo:: Bar::/]);

    is($loader->load_class('Class'), 'Bar::Class');
}

sub throw_exception_on_unknown_class : Test {
    my $self = shift;

    my $loader = $self->_build_loader;

    isa_ok(exception { $loader->load_class('Unknown') },
        'Lamework::Exception');
}

sub throw_on_class_with_syntax_errors : Test {
    my $self = shift;

    my $loader = $self->_build_loader;

    ok(exception { $loader->load_class('WithSyntaxErrors') });
}

sub _build_loader {
    my $self = shift;

    return Lamework::Loader->new(@_);
}

1;
