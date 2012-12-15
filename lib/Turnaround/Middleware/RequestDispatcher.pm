package Turnaround::Middleware::RequestDispatcher;

use strict;
use warnings;

use base 'Turnaround::Middleware';

use Encode ();
use Turnaround::HTTPException;

sub new {
    my $self = shift->SUPER::new(@_);

    $self->{encoding} ||= 'UTF-8';

    return $self;
}

sub call {
    my $self = shift;
    my ($env) = @_;

    $self->_dispatch($env);

    return $self->app->($env);
}

sub _dispatch {
    my $self = shift;
    my ($env) = @_;

    my $path   = $env->{PATH_INFO}      || '';
    my $method = $env->{REQUEST_METHOD} || 'GET';

    if ($self->{encoding}) {
        $path = Encode::decode($self->{encoding}, $path);
    }

    my $dispatcher = $self->{dispatcher} or die 'dispatcher required';

    my $dispatched_request =
      $dispatcher->dispatch($path, method => lc $method);
    Turnaround::HTTPException->throw(code => 404) unless $dispatched_request;

    $env->{'turnaround.dispatched_request'} = $dispatched_request;

    return $self;
}

1;
