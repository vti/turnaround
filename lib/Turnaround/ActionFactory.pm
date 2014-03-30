package Turnaround::ActionFactory;

use strict;
use warnings;

use base 'Turnaround::Factory';

sub new {
    my $self = shift->SUPER::new(@_);

    $self->{try} = 1;

    return $self;
}

1;
