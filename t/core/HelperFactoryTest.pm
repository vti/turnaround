package HelperFactoryTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Turnaround::HelperFactory;

use lib 't/core/HelperFactoryTest';

use Helper;

sub register_helper_as_sub : Test {
    my $self = shift;

    my $factory = $self->_build_factory;

    $factory->register_helper('foo' => sub {'bar'});

    my $foo = $factory->create_helper('foo');

    is($foo, 'bar');
}

sub register_helper_as_class : Test {
    my $self = shift;

    my $factory = $self->_build_factory;

    $factory->register_helper('foo' => 'Helper');

    my $foo = $factory->create_helper('foo')->hi;

    is($foo, 'there');
}

sub register_helper_as_instance : Test {
    my $self = shift;

    my $factory = $self->_build_factory;

    $factory->register_helper('foo' => Helper->new);

    my $foo = $factory->create_helper('foo')->hi;

    is($foo, 'there');
}

sub _build_factory {
    my $self = shift;

    return Turnaround::HelperFactory->new(@_);
}

1;
