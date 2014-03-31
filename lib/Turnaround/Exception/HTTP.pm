package Turnaround::Exception::HTTP;

use strict;
use warnings;

use base 'Turnaround::Exception::Base';

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{code} = $params{code};

    return $self;
}

sub code { $_[0]->{code} || 500 }

sub as_string { $_[0]->{message} }

1;
