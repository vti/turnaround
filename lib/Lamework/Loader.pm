package Lamework::Loader;

use strict;
use warnings;

use base 'Lamework::Base';

use Try::Tiny;
use Class::Load ();

use Lamework::Exception;

sub load_class {
    my $self = shift;
    my ($class) = @_;

    if (($class =~ s/^\+//) || !$self->{namespaces}) {
        return $class if $self->_try_load_class($class);
    }

    foreach my $namespace (@{$self->{namespaces}}) {
        if ($self->_try_load_class($namespace . $class)) {
            return $namespace . $class;
        }
    }

    $self->_try_load_class($class) or $self->_throw_not_found($class);

    return $class;
}

sub _try_load_class {
    my $self = shift;
    my ($class) = @_;

    return try {
        Class::Load::load_class($class);

        return 1;
    }
    catch {
        $class =~ s{::}{/}g;

        die $_ unless $_ =~ m{^Can't locate $class\.pm in \@INC };

        return 0;
    };
}

sub _throw_not_found {
    my $self = shift;
    my ($class) = @_;

    Lamework::Exception->throw("Class '$class' not found");
}

1;
