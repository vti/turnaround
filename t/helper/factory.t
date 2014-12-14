use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Turnaround::HelperFactory;

use lib 't/helper/HelperFactoryTest';

use Helper;

subtest 'throws when registering existing helper' => sub {
    my $factory = _build_factory();

    $factory->register_helper('foo' => sub { 'bar' });

    ok exception {
        $factory->register_helper('foo' => sub { 'bar' })
    };
};

subtest 'registers helper as sub' => sub {
    my $factory = _build_factory();

    $factory->register_helper('foo' => sub { 'bar' });

    my $foo = $factory->create_helper('foo');

    is $foo, 'bar';
};

subtest 'registers helper as class' => sub {
    my $factory = _build_factory();

    $factory->register_helper('foo' => 'Helper');

    my $foo = $factory->create_helper('foo')->hi;

    is $foo, 'there';
};

subtest 'registers helper as instance' => sub {
    my $factory = _build_factory();

    $factory->register_helper('foo' => Helper->new);

    my $foo = $factory->create_helper('foo')->hi;

    is $foo, 'there';
};

subtest 'autoloads methods' => sub {
    my $factory = _build_factory();

    my $foo = $factory->helper;

    ok($foo);
};

subtest 'does not autoload DESTROY method' => sub {
    my $factory = _build_factory();

    ok !$factory->DESTROY;
};

subtest 'does not autoload method starting with uppercase' => sub {
    my $factory = _build_factory();

    ok !$factory->BUILD;
};

subtest 'does not autoload private methods' => sub {
    my $factory = _build_factory();

    ok !$factory->_helper;
};

sub _build_factory {
    Turnaround::HelperFactory->new(@_);
}

done_testing;
