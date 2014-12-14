package Turnaround::Plugin::Mailer;

use strict;
use warnings;

use base 'Turnaround::Plugin';

use Carp qw(croak);
use Turnaround::Mailer;

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{services} = $params{services} || croak 'services required';
    $self->{config} = $params{config};
    $self->{service_name} ||= 'mailer';

    return $self;
}

sub startup {
    my $self = shift;

    my $config =
         $self->{config}
      || $self->{services}->service('config')->{$self->{service_name}}
      || {};

    croak 'mailer not configured' unless %$config;

    my $mailer = Turnaround::Mailer->new(%$config);
    $self->{services}->register($self->{service_name} => $mailer);
}

1;
