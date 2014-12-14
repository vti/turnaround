package Turnaround::Mailer::Test;

use strict;
use warnings;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{path} = $params{path};

    return $self;
}

sub send {
    my $self = shift;
    my ($message) = @_;

    open my $mail, '>>', $self->{path} or die "Can't open test file";
    print $mail $message;
    close $mail;

    return $self;
}

1;
