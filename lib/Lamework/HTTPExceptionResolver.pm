package Lamework::HTTPExceptionResolver;

use strict;
use warnings;

use base 'Lamework::Factory';

sub BUILD {
    my $self = shift;

    $self->{namespace} ||= 'Lamework::HTTPExceptionResolver::';
}

1;
