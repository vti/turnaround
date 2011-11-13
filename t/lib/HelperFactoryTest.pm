package HelperFactoryTest;

use strict;
use warnings;

use base 'FactoryTest';

use Test::More;

use Lamework::HelperFactory;

sub autoload_objects : Test {
    my $self = shift;

    my $factory = $self->_build_factory;

    my $foo = $factory->foo;

    ok($foo);
}

sub _build_factory {
    my $self = shift;

    return Lamework::HelperFactory->new(@_);
}

1;
