package Turnaround::Middleware::Session::Cookie;

use strict;
use warnings;

use base 'Plack::Middleware::Session::Cookie';

sub new {
    my $class = shift;
    my (%params) = @_;

    my $services = delete $params{services};

    my $config = $services->service('config') || {};
    $config = $config->{session} || {};

    return $class->SUPER::new(%$config, %params);
}

1;
