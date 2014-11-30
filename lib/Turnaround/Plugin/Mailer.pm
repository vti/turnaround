package Turnaround::Plugin::Mailer;

use strict;
use warnings;

use base 'Turnaround::Plugin';

use Turnaround::Mailer;

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{services} = $params{services} || die 'services required';
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

    my $mailer = Turnaround::Mailer->new(%$config);
    $self->{services}->register($self->{service_name} => $mailer);
}

1;
