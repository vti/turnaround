package Turnaround::Builder;

use strict;
use warnings;

use base 'Turnaround::Base';

use Scalar::Util ();

use Turnaround::Loader;

sub BUILD {
    my $self = shift;

    $self->{middleware} ||= [];
}

sub add_middleware {
    my $self = shift;
    my ($middleware, @args) = @_;

    push @{$self->{middleware}}, {name => $middleware, args => [@args]};
}

sub wrap {
    my $self = shift;
    my ($app) = @_;

    my $loader = $self->_build_loader;

    foreach my $middleware (reverse @{$self->{middleware}}) {
        my $instance = $middleware->{name};

        if (ref $instance eq 'CODE') {
            $app = $instance->($app);
        }
        elsif (!Scalar::Util::blessed($instance)) {
            $instance = $loader->load_class($instance);
            $instance = $instance->new(@{$middleware->{args}});

            $app = $instance->wrap($app);
        }
    }

    return $app;
}

sub _build_loader {
    my $self = shift;

    return Turnaround::Loader->new(
        namespaces => [qw/Turnaround::Middleware:: Plack::Middleware::/]);
}

1;
