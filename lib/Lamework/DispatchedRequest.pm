package Lamework::DispatchedRequest;

use strict;
use warnings;

use base 'Lamework::Base';

require Carp;

sub captures { $_[0]->{captures} }

sub build_path { Carp::croak('Not implemented') }

1;
