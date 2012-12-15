package Turnaround::HTTPException;

use strict;
use warnings;

use base 'Turnaround::Exception::Base';

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{code} = $params{code};

    return $self;
}

sub code { $_[0]->{code} }

sub to_string { $_[0]->message }

1;
