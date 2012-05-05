package Turnaround::RESTAction;

use strict;
use warnings;

use base 'Turnaround::Action';

sub run {
    my $self = shift;

    my $http_method = $self->req->param('_method');
    if (!$http_method || $http_method !~ m/^GET|POST|PUT|DELETE|HEAD$/) {
        $http_method = $self->env->{REQUEST_METHOD};
    }
    $http_method = uc $http_method;

    if ($self->can("method_$http_method")) {
        my $method = "method_$http_method";
        return $self->$method;
    }
    elsif ($self->can('method_ALL')) {
        return $self->method_ALL;
    }

    return;
}

1;
