use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Turnaround::HelperFactory::Persistent;

use lib 't/helper/HelperFactoryTest';

use Helper;

subtest 'should_return_same_instance' => sub {
    my $factory = _build_factory();

    $factory->register_helper('foo' => 'Helper');

    my $foo = $factory->create_helper('foo');
    my $bar = $factory->create_helper('foo');

    is("$foo", "$bar");
};

sub _build_factory {
    return Turnaround::HelperFactory::Persistent->new(@_);
}

done_testing;
