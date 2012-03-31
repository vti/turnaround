package Lamework::Middleware::HTTPExceptions;

use strict;
use warnings;

use base 'Plack::Middleware::HTTPExceptions';

sub new {
    my $self = shift->SUPER::new(@_);

    die 'resolver is required' unless $self->{resolver};

    return $self;
}

sub transform_error {
    my ($self, $e, $env) = @_;

    return $self->{resolver}->resolve($e, $env);
}

1;
