package Turnaround::DispatchedRequest::Routes;

use strict;
use warnings;

use base 'Turnaround::DispatchedRequest';

sub build_path {
    my $self = shift;

    return $self->{routes}->build_path(@_);
}

1;
