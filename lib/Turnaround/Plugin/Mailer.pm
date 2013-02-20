package Turnaround::Plugin::Mailer;

use strict;
use warnings;

use base 'Turnaround::Plugin';

use Turnaround::Mailer;

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{services} = $params{services} || die 'services required';
    $self->{config}   = $params{config}   || die 'config required';
    $self->{service_name} ||= 'mailer';

    return $self;
}

sub startup {
    my $self = shift;

    my $mailer = Turnaround::Mailer->new(%{$self->{config} || {}});
    $self->{services}->register($self->{service_name} => $mailer);
}

1;
