package Turnaround::Mailer::SMTP;

use strict;
use warnings;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{host}     = $params{host};
    $self->{port}     = $params{port};
    $self->{username} = $params{username};
    $self->{password} = $params{password};

    return $self;
}

sub send {
    my $self = shift;
    my ($message) = @_;

    require Email::Sender::Simple;
    require Email::Sender::Transport::SMTP::TLS;

    my $sender = Email::Sender::Transport::SMTP::TLS->new(
        host     => $self->{host},
        port     => $self->{port},
        username => $self->{username},
        password => $self->{password}
    );

    Email::Sender::Simple->send($message, {transport => $sender});

    return $self;
}

1;
