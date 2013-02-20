package Turnaround::HelperFactory::Persistent;

use strict;
use warnings;

use base 'Turnaround::HelperFactory';

sub new {
    my $self = shift->SUPER::new(@_);

    $self->{cache} = {};

    return $self;
}

sub create_helper {
    my $self = shift;
    my ($name) = @_;

    if (exists $self->{cache}->{$name}) {
        return $self->{cache}->{$name};
    }

    return $self->{cache}->{$name} = $self->SUPER::create_helper(@_);
}

1;
