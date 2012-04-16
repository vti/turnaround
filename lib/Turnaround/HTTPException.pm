package Turnaround::HTTPException;

use strict;
use warnings;

use base 'Turnaround::Exception::Base';

sub code { $_[0]->{code} }

sub location { $_[0]->{location} }

sub to_string { $_[0]->message }

1;
