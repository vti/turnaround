package Turnaround::Request;

use strict;
use warnings;

use base 'Plack::Request';

use Encode ();
use Hash::MultiValue;

use Turnaround::Response;

sub new {
    my $class = shift;
    my ($env, %options) = @_;

    my $self = $class->SUPER::new($env);

    $self->{encoding} = $options{encoding} ||= 'UTF-8';

    return $self;
}

sub new_response {
    my $self = shift;

    return Turnaround::Response->new(@_);
}

sub query_parameters {
    my $self = shift;

    $self->env->{'plack.request.query'} ||= do {
        $self->_decode_parameters($self->uri->query_form);
    };
}

sub _parse_request_body {
    my $self = shift;

    my $retval = $self->SUPER::_parse_request_body(@_);

    $self->env->{'plack.request.body'} =
      $self->_decode_parameters($self->env->{'plack.request.body'});

    return $retval;
}

sub _decode_parameters {
    my $self = shift;

    my @flatten = @_ == 1 ? $_[0]->flatten : @_;

    my $encoding = $self->{encoding};

    my @decoded;
    while (my ($key, $val) = splice @flatten, 0, 2) {
        push @decoded, Encode::decode($encoding, $key),
          Encode::decode($encoding, $val);
    }

    return Hash::MultiValue->new(@decoded);
}

1;
