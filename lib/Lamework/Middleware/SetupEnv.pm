package Lamework::Middleware::SetupEnv;

use strict;
use warnings;

use base 'Lamework::Middleware';

sub call {
    my $self = shift;
    my ($env) = @_;

    $self->{configurator}->setup($env);

    return $self->app->($env);
}

1;
