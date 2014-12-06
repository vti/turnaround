package Turnaround::Loader;

use strict;
use warnings;

require Carp;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{namespaces} = $params{namespaces};

    return $self;
}

sub is_class_loaded {
    my $self = shift;
    my ($class) = @_;

    Carp::croak('class name is required') unless $class;

    my $path = $self->_class_to_path($class);

    return 1 if exists $INC{$path} && defined $INC{$path};

    {
        no strict 'refs';
        for (keys %{"$class\::"}) {
            return 1 if defined &{"$class\::$_"};
        }
    }

    return 0;
}

sub try_load_class {
    my $self = shift;
    my ($class) = @_;

    Carp::croak('class name is required') unless $class;

    my $class_loaded = $self->_try_load_class_from_namespaces($class);
    return $class_loaded if $class_loaded;

    return unless $self->_try_load_class($class);

    return $class;
}

sub load_class {
    my $self = shift;
    my ($class) = @_;

    Carp::croak('class name is required') unless $class;

    my $class_loaded = $self->_try_load_class_from_namespaces($class);
    return $class_loaded if $class_loaded;

    $self->_try_load_class($class, throw => 1);
    return $class;
}

sub _try_load_class_from_namespaces {
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

    return;
}

sub _try_load_class {
    my $self = shift;
    my ($class, %params) = @_;

    Carp::croak("Invalid class name '$class'") unless $class =~ m/^[a-z0-9:]+$/i;

    my $path = $self->_class_to_path($class);

    return 1 if $self->is_class_loaded($class);

    eval {
        require $path;

        return 1;
    } || do {
        my $e = $@;

        delete $INC{$path};

        {
            no strict 'refs';

            %{"$class\::"} = ();
        }

        Carp::croak($e)
          if $params{throw} || $e !~ m{^Can't locate \Q$path\E in \@INC };

        return 0;
    };
}

sub _class_to_path {
    my $self = shift;
    my ($class) = @_;

    $class =~ s{::}{/}g;

    return $class . '.pm';
}

1;
