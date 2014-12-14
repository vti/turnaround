package Turnaround::Mailer::Sendmail;

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

    my $path = "| $self->{path} -t -oi -oem";

    open my $fh, '>', $path or croak "Can't start sendmail: $!";
    print $fh $message;
    close $fh;

    return $self;
}

1;
