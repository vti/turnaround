package FooInstance;

use strict;
use warnings;

sub new {
    my $class = shift;

    my $self = {@_};
    bless $self, $class;

    return $self;
}

sub set_bar {
    my $self = shift;
    my ($value) = @_;

    $self->{bar} = $value;

    return $self;
}

sub get_bar {
    my $self = shift;
    my ($bar) = @_;

    return $self->{bar};
}

1;
