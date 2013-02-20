package HelperFactoryPersistentTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Turnaround::HelperFactory::Persistent;

use lib 't/core/HelperFactoryTest';

use Helper;

sub should_return_same_instance : Test {
    my $self = shift;

    my $factory = $self->_build_factory;

    $factory->register_helper('foo' => 'Helper');

    my $foo = $factory->create_helper('foo');
    my $bar = $factory->create_helper('foo');

    is("$foo", "$bar");
}

sub _build_factory {
    my $self = shift;

    return Turnaround::HelperFactory::Persistent->new(@_);
}

1;
