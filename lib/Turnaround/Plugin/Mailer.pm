package Turnaround::Plugin::Mailer;

use strict;
use warnings;

use base 'Turnaround::Plugin';

use Turnaround::Mailer;

sub BUILD {
    my $self = shift;

    $self->{service_name} ||= 'mailer';
}

sub startup {
    my $self = shift;

    my $mailer = Turnaround::Mailer->new(%{$self->{config} || {}});
    $self->{services}->register($self->{service_name} => $mailer);
}

1;
