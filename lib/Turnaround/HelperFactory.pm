package Turnaround::HelperFactory;

use strict;
use warnings;

use base 'Turnaround::Factory';

use Scalar::Util ();

our $AUTOLOAD;

sub register_helper {
    my $self = shift;
    my ($name, $object) = @_;

    $self->{helpers}->{$name} = $object;
}

sub create_helper {
    my $self = shift;
    my ($name) = @_;

    if (exists $self->{helpers}->{$name}) {
        my $helper = $self->{helpers}->{$name};

        return
            ref $helper eq 'CODE' ? $helper->()
          : Scalar::Util::blessed($helper) ? $helper
          :                                  $self->build($helper);
    }

    return $self->build($name);
}

sub DESTROY { }

sub AUTOLOAD {
    my $self = shift;

    my ($method) = (split /::/, $AUTOLOAD)[-1];

    return if $method =~ /[A-Z]/;

    return $self->create_helper($method, @_);
}

1;
