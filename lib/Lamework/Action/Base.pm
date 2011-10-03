package Lamework::Action::Base;

use strict;
use warnings;

use base 'Lamework::Base';

use Scalar::Util qw(weaken);

use Lamework::Request;

sub BUILD {
    my $self = shift;

    weaken $self->{app};
}

sub run {
    my $self = shift;

    die "Method 'run' in action '" . ref($self) . "' must be defined.";
}

sub env {
    my $self = shift;

    return $self->{env};
}

sub app {
    my $self = shift;

    return $self->{app};
}

sub req {
    my $self = shift;

    $self->{req} ||= Lamework::Request->new($self->env);

    return $self->{req};
}

sub res {
    my $self = shift;

    $self->{res} ||= $self->req->new_response;

    return $self->{res};
}

1;
