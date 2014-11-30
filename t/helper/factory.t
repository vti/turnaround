use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Turnaround::HelperFactory;

use lib 't/helper/HelperFactoryTest';

use Helper;

subtest 'throw_when_registering_existing_helper' => sub {
    my $factory = _build_factory();

    $factory->register_helper('foo' => sub { 'bar' });

    ok exception {
        $factory->register_helper('foo' => sub { 'bar' })
    };
};

subtest 'register_helper_as_sub' => sub {
    my $factory = _build_factory();

    $factory->register_helper('foo' => sub { 'bar' });

    my $foo = $factory->create_helper('foo');

    is $foo, 'bar';
};

subtest 'register_helper_as_class' => sub {
    my $factory = _build_factory();

    $factory->register_helper('foo' => 'Helper');

    my $foo = $factory->create_helper('foo')->hi;

    is $foo, 'there';
};

subtest 'register_helper_as_instance' => sub {
    my $factory = _build_factory();

    $factory->register_helper('foo' => Helper->new);

    my $foo = $factory->create_helper('foo')->hi;

    is $foo, 'there';
};

subtest 'autoload_objects' => sub {
    my $factory = _build_factory();

    my $foo = $factory->helper;

    ok($foo);
};

sub _build_factory {
    Turnaround::HelperFactory->new(@_);
}

done_testing;
