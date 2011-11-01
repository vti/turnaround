package Lamework::Request;

use strict;
use warnings;

use base 'Plack::Request';

use Encode ();

use Lamework::Response;

sub new {
    my $class = shift;
    my ($env, %options) = @_;

    my $self = $class->SUPER::new($env);

    $self->{encoding} = $options{encoding} ||= 'UTF-8';

    return $self;
}

sub new_response {
    my $self = shift;

    return Lamework::Response->new(@_);
}

sub query_parameters {
    my $self = shift;

    $self->env->{'plack.request.query'} ||= do {
        my %values = $self->uri->query_form;
        foreach my $value (keys %values) {
            $values{Encode::decode($self->{encoding}, $value)} =
              Encode::decode($self->{encoding}, delete $values{$value});
        }

        Hash::MultiValue->new(%values);
    };
}

sub _parse_request_body {
    my $self = shift;

    my $retval = $self->SUPER::_parse_request_body(@_);

    my @keys = $self->env->{'plack.request.body'}->keys;
    foreach my $key (@keys) {
        my @values = $self->{env}->{'plack.request.body'}->get_all($key);
        $self->{env}->{'plack.request.body'}->remove($key);

        $key = Encode::decode($self->{encoding}, $key);
        @values = map { Encode::decode($self->{encoding}, $_) } @values;

        $self->{env}->{'plack.request.body'}->add($key => @values);
    }

    return $retval;
}

1;
