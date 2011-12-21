package Lamework::HTTPException;

use strict;
use warnings;

use base 'Lamework::Exception';

sub code { $_[0]->{code} }

sub location { $_[0]->{location} }

1;
