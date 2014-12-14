package Turnaround::Mailer::Test;

use strict;
use warnings;

use Carp qw(croak);

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{path} = $params{path};

    return $self;
}

sub send_message {
    my $self = shift;
    my ($message) = @_;

    open my $mail, '>>', $self->{path} or croak "Can't open test file: $!";
    print $mail $message;
    close $mail;

    return $self;
}

1;
