package ActionResponseResolverTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Turnaround::Response;
use Turnaround::ActionResponseResolver;

sub return_undef_on_undef : Test {
    my $self = shift;

    my $resolver = $self->_build_resolver;

    ok(not defined $resolver->resolve);
}

sub return_arrayref_on_arrayref : Test {
    my $self = shift;

    my $resolver = $self->_build_resolver;

    is_deeply($resolver->resolve([200, [], ['body']]), [200, [], ['body']]);
}

sub return_code_on_code : Test {
    my $self = shift;

    my $resolver = $self->_build_resolver;

    is(ref $resolver->resolve(sub { }), 'CODE');
}

sub return_finalized_object : Test {
    my $self = shift;

    my $resolver = $self->_build_resolver;

    is_deeply(
        $resolver->resolve(Turnaround::Response->new(200)),
        [200, ['Content-Type' => 'text/html'], []]
    );
}

sub return_json_on_hashref : Test {
    my $self = shift;

    my $resolver = $self->_build_resolver;

    is_deeply($resolver->resolve({a => 'b'}),
        [200, ['Content-Type' => 'application/json'], ['{"a":"b"}']]);
}

sub _build_resolver {
    my $self = shift;
    my (%params) = @_;

    return Turnaround::ActionResponseResolver->new(@_);
}

1;
