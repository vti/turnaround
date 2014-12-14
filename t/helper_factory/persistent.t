use strict;
use warnings;

use Test::More;

use Turnaround::HelperFactory::Persistent;

use lib 't/helper_t';

use Helper;

subtest 'should return same instance' => sub {
    my $factory = _build_factory();

    $factory->register_helper('foo' => 'Helper');

    my $foo = $factory->create_helper('foo');
    my $bar = $factory->create_helper('foo');

    is "$foo", "$bar";
};

sub _build_factory { Turnaround::HelperFactory::Persistent->new(@_) }

done_testing;
