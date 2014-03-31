package Turnaround::DispatchedRequest::Routes;

use strict;
use warnings;

use base 'Turnaround::DispatchedRequest';

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{routes} = $params{routes};

    return $self;
}

sub build_path {
    my $self = shift;

    return $self->{routes}->build_path(@_);
}

1;
