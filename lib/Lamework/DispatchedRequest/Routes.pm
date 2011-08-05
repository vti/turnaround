package Lamework::DispatchedRequest::Routes;

use strict;
use warnings;

use base 'Lamework::DispatchedRequest';

sub build_path {
    my $self = shift;

    return $self->{routes}->build_path(@_);
}

1;
