package Foo;

use strict;
use warnings;

use Turnaround::Mixin 'Mixin';

sub new {
    my $class = shift;

    my $self = {@_};
    bless $self, $class;

    $self->{data} = 123;

    return $self;
}

sub foo {
    'foo';
}

sub modified_before {
    my $self = shift;

    return 'before';
}

sub modified_after {
    my $self = shift;

    return 'before';
}

sub modified_around {
    my $self = shift;

    $self->{data} . 'inner' . join('', @_);
}

sub _private {
}

1;
