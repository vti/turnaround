use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Turnaround::ServiceContainer;

subtest 'throws on getting unknown service' => sub {
    my $c = _build_container();

    like exception { $c->service('foo') }, qr/unknown service 'foo'/;
};

subtest 'throws on registering already registered service' => sub {
    my $c = _build_container();

    $c->register(foo => 'bar');

    like exception { $c->register(foo => 'baz') },
      qr/service 'foo' already registered/;
};

subtest 'registers scalar service' => sub {
    my $c = _build_container();

    $c->register(foo => 'bar');

    is $c->service('foo'), 'bar';
};

subtest 'registers instance service' => sub {
    my $c = _build_container();

    $c->register(foo => FooInstance->new);

    isa_ok($c->service('foo'), 'FooInstance');
};

subtest 'registers service via sub' => sub {
    my $c = _build_container();

    $c->register(foo => sub { 'foo' });

    is($c->service('foo'), 'foo');
};

sub _build_container { Turnaround::ServiceContainer->new(@_) }

done_testing;

package FooInstance;
sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

1;
