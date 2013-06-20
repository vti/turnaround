package Turnaround::Exception::Base;

use strict;
use warnings;

use overload
  '""'     => sub { $_[0]->to_string },
  'bool'   => sub { 1 },
  fallback => 1;

require Carp;
use Scalar::Util ();

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{message} = $params{message};

    $self->{file} = $params{caller}->[1];
    $self->{line} = $params{caller}->[2];

    return $self;
}

sub message {
    $_[0]->{message};
}

sub throw {
    my $class = shift;
    my ($message, %params) = @_;

    Carp::croak($class->new(message => $message, %params, caller => [caller]));
}

sub to_string { &as_string }

sub as_string {
    my $self = shift;

    return sprintf("%s at %s line %s.",
        $self->{message}, $self->{file}, $self->{line});
}

1;
