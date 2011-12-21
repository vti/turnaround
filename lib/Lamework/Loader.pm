package Lamework::Loader;

use strict;
use warnings;

use base 'Lamework::Base';

use Try::Tiny;

use Lamework::Exception ();

sub load_class {
    my $self = shift;
    my ($class) = @_;

    if (($class =~ s/^\+//) || !$self->{namespaces}) {
        return $class if $self->try_load_class($class);
    }

    foreach my $namespace (@{$self->{namespaces}}) {
        if ($self->try_load_class($namespace . $class)) {
            return $namespace . $class;
        }
    }

    $self->try_load_class($class) or $self->_throw_not_found($class);

    return $class;
}

sub is_class_loaded {
    my $self = shift;
    my ($class) = @_;

    my $path = $class;
    $path =~ s{::}{/}g;
    $path .= '.pm';

    return 1 if exists $INC{$path} && $INC{$path};

    return 1 if $class->can('isa');

    return 0;
}

sub try_load_class {
    my $self = shift;
    my ($class) = @_;

    die 'Invalid class name' unless $class =~ m/^[a-z0-9:]+$/i;

    my $path = $class;
    $path =~ s{::}{/}g;
    $path .= '.pm';

    return try {
        if (!$self->is_class_loaded($class)) {
            require $path;
        }

        return 1;
    }
    catch {
        die $_ unless $_ =~ m{^Can't locate $path in \@INC };

        return 0;
    };
}

sub _throw_not_found {
    my $self = shift;
    my ($class) = @_;

    Lamework::Exception::throw('Lamework::Exception',
        "Class '$class' not found");
}

1;
