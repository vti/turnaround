package Turnaround::Action::REST;

use strict;
use warnings;

use base 'Turnaround::Action';

sub run {
    my $self = shift;

    my $method = uc($self->req->param('_method') || $self->req->method);
    if ($self->can($method)) {
        $self->$method;
    }
    else {
        $self->throw_method_not_allowed;
    }
}

sub new_created_response {
    my $self = shift;
    my ($headers, $content) = @_;

    return $self->new_response(201, $headers, $content);
}

sub new_no_content_response {
    my $self = shift;
    my ($headers, $content) = @_;

    return $self->new_response(204, $headers, $content);
}

sub throw_bad_request {
    my $self = shift;
    my ($message) = @_;

    $self->throw_error($message || 'Bad request', 400);
}

sub throw_validation {
    my $self = shift;
    my ($message) = @_;

    $self->throw_error($message, 422);
}

sub throw_method_not_allowed {
    my $self = shift;
    my ($message) = @_;

    $self->throw_error($message || 'Method not allowed', 405);
}

1;
