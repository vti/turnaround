use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Turnaround::Builder;

subtest 'adds middleware' => sub {
    my $builder = _build_builder();

    $builder->add_middleware('ViewDisplayer');

    is_deeply($builder->list_middleware, [qw/ViewDisplayer/]);
};

subtest 'adds inline middleware' => sub {
    my $builder = _build_builder();

    $builder->add_middleware(sub { });

    is_deeply($builder->list_middleware, ['__ANON__']);
};

subtest 'throws when inserts before unknown middleware' => sub {
    my $builder = _build_builder();

    like exception {
        $builder->insert_before_middleware('ViewDisplayer', 'ActionBuilder')
    }, qr/Unknown middleware 'ViewDisplayer'/;
};

subtest 'inserts before' => sub {
    my $builder = _build_builder();

    $builder->add_middleware('ViewDisplayer');
    $builder->insert_before_middleware('ViewDisplayer', 'ActionBuilder');

    is_deeply($builder->list_middleware, [qw/ActionBuilder ViewDisplayer/]);
};

subtest 'inserts after' => sub {
    my $builder = _build_builder();

    $builder->add_middleware('ViewDisplayer');
    $builder->insert_after_middleware('ViewDisplayer', 'ActionBuilder');

    is_deeply($builder->list_middleware, [qw/ViewDisplayer ActionBuilder/]);
};

subtest 'wraps' => sub {
    my $builder = _build_builder();

    my $stack = [];

    $builder->add_middleware('+TestMiddleware');
    $builder->add_middleware(
        sub {
            my $app = shift;
            sub { push @$stack, 'two'; $app->() }
        }
    );
    $builder->add_middleware(
        sub {
            my $app = shift;
            sub { push @$stack, 'three'; $app->() }
        }
    );

    my $app = $builder->wrap(sub { push @$stack, 'four'; });

    $app->();

    is_deeply($stack, [qw/two three four/]);
};

sub _build_builder {
    return Turnaround::Builder->new(@_);
}

done_testing;

package TestMiddleware;

use strict;
use warnings;

use base 'Turnaround::Middleware';

sub call {
    my $self = shift;
    my ($env) = @_;

    return $self->app->($env);
}

1;
