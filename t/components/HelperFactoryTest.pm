package HelperFactoryTest;

use strict;
use warnings;

use base 'TestBase';

use lib 't/components/HelperFactoryTest';

use Test::More;

use Turnaround::HelperFactory;

sub autoload_objects : Test {
    my $self = shift;

    my $factory = $self->_build_factory;

    my $foo = $factory->foo;

    ok($foo);
}

sub _build_factory {
    my $self = shift;

    return Turnaround::HelperFactory->new(@_);
}

1;
