package Turnaround::Builder;

use strict;
use warnings;

use base 'Turnaround::Base';

use Scalar::Util ();

use Turnaround::Loader;

sub BUILD {
    my $self = shift;

    $self->{middleware} ||= [];
    $self->{namespaces} ||= [];

    $self->{loader} ||= Turnaround::Loader->new(
        namespaces => [
            @{$self->{namespaces}},
            qw/Turnaround::Middleware:: Plack::Middleware::/
        ]
    );
}

sub add_middleware {
    my $self = shift;
    my ($middleware, @args) = @_;

    push @{$self->{middleware}}, {name => $middleware, args => [@args]};
}

sub wrap {
    my $self = shift;
    my ($app) = @_;

    my $loader = $self->{loader};

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

1;
