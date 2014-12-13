use strict;
use warnings;
use utf8;

use Test::More;

use Encode ();

use Turnaround::Response;
use Turnaround::ActionResponseResolver;

subtest 'return_undef_on_undef' => sub {
    my $resolver = _build_resolver();

    ok(not defined $resolver->resolve);
};

subtest 'return_arrayref_on_string' => sub {
    my $resolver = _build_resolver();

    is_deeply(
        $resolver->resolve('привет'),
        [
            200,
            ['Content-Type' => 'text/html'],
            [Encode::encode('UTF-8', 'привет')]
        ]
    );
};

subtest 'return_arrayref_on_arrayref' => sub {
    my $resolver = _build_resolver();

    is_deeply($resolver->resolve([200, [], ['body']]), [200, [], ['body']]);
};

subtest 'return_code_on_code' => sub {
    my $resolver = _build_resolver();

    is(ref $resolver->resolve(sub { }), 'CODE');
};

subtest 'return_finalized_object' => sub {
    my $resolver = _build_resolver();

    is_deeply(
        $resolver->resolve(Turnaround::Response->new(200)),
        [200, ['Content-Type' => 'text/html'], []]
    );
};

sub _build_resolver {
    my $self = shift;
    my (%params) = @_;

    return Turnaround::ActionResponseResolver->new(@_);
}

done_testing;
