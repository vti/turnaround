package Lamework::Request;

use strict;
use warnings;

use base 'Plack::Request';

use Lamework::Response;

sub new_response {
    my $self = shift;

    return Lamework::Response->new(@_);
}

1;
