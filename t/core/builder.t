use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Turnaround::Builder;

subtest 'add_middleware' => sub {
    my $builder = _build_builder();

    $builder->add_middleware('ViewDisplayer');

    is_deeply($builder->list_middleware, [qw/ViewDisplayer/]);
};

subtest 'insert_before' => sub {
    my $builder = _build_builder();

    $builder->add_middleware('ViewDisplayer');
    $builder->insert_before_middleware('ViewDisplayer', 'ActionBuilder');

    is_deeply($builder->list_middleware, [qw/ActionBuilder ViewDisplayer/]);
};

subtest 'insert_after' => sub {
    my $builder = _build_builder();

    $builder->add_middleware('ViewDisplayer');
    $builder->insert_after_middleware('ViewDisplayer', 'ActionBuilder');

    is_deeply($builder->list_middleware, [qw/ViewDisplayer ActionBuilder/]);
};

subtest 'remove' => sub {
    my $builder = _build_builder();

    $builder->add_middleware('ViewDisplayer');
    $builder->add_middleware('ActionBuilder');
    $builder->remove_middleware('ViewDisplayer');

    is_deeply($builder->list_middleware, [qw/ActionBuilder/]);
};

subtest 'replace' => sub {
    my $builder = _build_builder();

    $builder->add_middleware('ViewDisplayer');
    $builder->add_middleware('ActionBuilder');
    $builder->replace_middleware('ViewDisplayer', 'Static');

    is_deeply($builder->list_middleware, [qw/Static ActionBuilder/]);
};

subtest 'wrap' => sub {
    my $builder = _build_builder();

    my $stack = [];

    $builder->add_middleware(
        sub {
            my $app = shift;
            sub { push @$stack, 'one'; $app->() }
        }
    );
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

    is_deeply($stack, [qw/one two three four/]);
};

sub _build_builder {
    return Turnaround::Builder->new(@_);
}

done_testing;
