package Lamework::Loader;

use strict;
use warnings;

use base 'Lamework::Base';

use Lamework::Exception::ClassNotFound;

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

    return 1 if exists $INC{$path} && defined $INC{$path};

    {
        no strict 'refs';

        return 1 if @{"$class\::ISA"};

        return 1 if grep { defined &{$_} } keys %{"$class\::"};
    }

    return 0;
}

sub try_load_class {
    my $self = shift;
    my ($class) = @_;

    die "Invalid class name '$class'" unless $class =~ m/^[a-z0-9:]+$/i;

    my $path = $class;
    $path =~ s{::}{/}g;
    $path .= '.pm';

    return 1 if $self->is_class_loaded($class);

    eval {
        require $path;

        return 1;
    }
    or do {
        my $e = $@;

        delete $INC{$path};

        {
            no strict 'refs';

            %{"$class\::"} = ();
        }

        $e->rethrow unless $e =~ m{^Can't locate \Q$path\E in \@INC };

        return 0;
    };
}

sub _throw_not_found {
    my $self = shift;
    my ($class) = @_;

    Lamework::Exception::ClassNotFound->throw(message => "Class '$class' not found");
}

1;
