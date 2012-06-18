package BuilderTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Turnaround::Builder;

sub add_middleware : Test {
    my $self = shift;

    my $builder = $self->_build_builder;

    $builder->add_middleware('ViewDisplayer');

    is_deeply($builder->list_middleware, [qw/ViewDisplayer/]);
}

sub insert_before : Test {
    my $self = shift;

    my $builder = $self->_build_builder;

    $builder->add_middleware('ViewDisplayer');
    $builder->insert_before_middleware('ViewDisplayer', 'ActionBuilder');

    is_deeply($builder->list_middleware, [qw/ActionBuilder ViewDisplayer/]);
}

sub insert_after : Test {
    my $self = shift;

    my $builder = $self->_build_builder;

    $builder->add_middleware('ViewDisplayer');
    $builder->insert_after_middleware('ViewDisplayer', 'ActionBuilder');

    is_deeply($builder->list_middleware, [qw/ViewDisplayer ActionBuilder/]);
}

sub remove : Test {
    my $self = shift;

    my $builder = $self->_build_builder;

    $builder->add_middleware('ViewDisplayer');
    $builder->add_middleware('ActionBuilder');
    $builder->remove_middleware('ViewDisplayer');

    is_deeply($builder->list_middleware, [qw/ActionBuilder/]);
}

sub replace : Test {
    my $self = shift;

    my $builder = $self->_build_builder;

    $builder->add_middleware('ViewDisplayer');
    $builder->add_middleware('ActionBuilder');
    $builder->replace_middleware('ViewDisplayer', 'Static');

    is_deeply($builder->list_middleware, [qw/Static ActionBuilder/]);
}

sub wrap : Test {
    my $self = shift;

    my $builder = $self->_build_builder;

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
}

sub _build_builder {
    my $self = shift;

    return Turnaround::Builder->new(@_);
}

1;
