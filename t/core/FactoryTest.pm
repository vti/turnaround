package FactoryTest;

use strict;
use warnings;

use base 'TestBase';

use lib 't/core/FactoryTest';

use Test::More;
use Test::Fatal;

use Turnaround::Factory;

sub build_an_object : Test {
    my $self = shift;

    my $factory = $self->_build_factory;

    my $foo = $factory->build('Foo');

    ok($foo);
}

sub not_throw_on_unknown_class : Test {
    my $self = shift;

    my $factory = $self->_build_factory(try => 1);

    ok !$factory->build('Unknown');
}

sub throw_on_unknown_class : Test {
    my $self = shift;

    my $factory = $self->_build_factory;

    like exception { $factory->build('Unknown') },
      qr/Can't locate Unknown\.pm in \@INC/;
}

sub rethrow_during_creation_errors : Test {
    my $self = shift;

    my $factory = $self->_build_factory;
    ok exception { $factory->build('DieDuringCreation') };
}

sub _build_factory {
    my $self = shift;

    return Turnaround::Factory->new(@_);
}

1;
