package Lamework::Middleware::RequestDispatcher;

use strict;
use warnings;

use base 'Lamework::Middleware';

use Lamework::Env;
use Lamework::Exception;

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

    my $dispatcher = $self->{dispatcher} or die 'dispatcher required';

    my $dispatched_request =
      $dispatcher->dispatch($path, method => lc $method);
    raise 'Lamework::HTTPException', code => 404 unless $dispatched_request;

    $env = Lamework::Env->new($env);

    $env->set(dispatched_request => $dispatched_request);

    return $self;
}

1;
