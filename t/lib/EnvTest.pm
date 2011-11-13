package EnvTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Lamework::Env;

sub set_get_variables : Test {
    my $self = shift;

    my $env = $self->_build_env({});

    $env->set(foo => 'bar');

    is($env->get('foo'), 'bar');
}

sub return_hashref : Test {
    my $self = shift;

    my $env = $self->_build_env({});

    $env->set(foo => 'bar');

    is_deeply($env->to_hash, {'lamework.foo' => 'bar'});
}

sub behave_as_hashref : Test {
    my $self = shift;

    my $env = $self->_build_env({});

    $env->set(foo => 'bar');

    is($env->{'lamework.foo'}, 'bar');
}

sub throw_when_no_env_was_passed : Test {
    my $self = shift;

    ok(exception { $self->_build_env });
}

sub _build_env {
    my $self = shift;

    return Lamework::Env->new(@_);
}

1;
