package Turnaround::Mixin;

use strict;
use warnings;

use Turnaround::Loader;

my $CALLER;
my @MIXINS;

sub import {
    my ($class, @mixins) = @_;

    return unless @mixins;

    @MIXINS = @mixins;
    $CALLER = (caller)[0];
}

sub CHECK {
    foreach my $mixin (@MIXINS) {
        Turnaround::Loader->new->load_class($mixin);

        my @methods = _get_public_methods($mixin);
        foreach my $method (@methods) {
            no strict 'refs';
            _install_sub($CALLER, $method, \*{"$mixin\::$method"});
        }

        my @before_methods = _get_before_methods($mixin);
        foreach my $method (@before_methods) {
            my $orig = _delete_sub($CALLER, $method);

            no strict 'refs';
            my $new_method = *{"$mixin\::BEFORE_$method"}{CODE};

            _install_sub(
                $CALLER, $method,
                sub {
                    $new_method->(@_);

                    *{$orig}{CODE}->(@_);
                }
            );
        }

        my @after_methods = _get_after_methods($mixin);
        foreach my $method (@after_methods) {
            my $orig = _delete_sub($CALLER, $method);

            no strict 'refs';
            my $new_method = *{"$mixin\::AFTER_$method"}{CODE};

            _install_sub(
                $CALLER, $method,
                sub {
                    my ($self, @args) = @_;

                    my $retval = *{$orig}{CODE}->($self, @args);

                    $new_method->($self, @args);

                    return $retval;
                }
            );
        }

        my @around_methods = _get_around_methods($mixin);
        foreach my $method (@around_methods) {
            my $orig = _delete_sub($CALLER, $method);

            no strict 'refs';
            my $new_method = *{"$mixin\::AROUND_$method"}{CODE};

            _install_sub(
                $CALLER, $method,
                sub {
                    my ($self, @args) = @_;

                    $new_method->($self, *{$orig}{CODE}, @args);
                }
            );
        }
    }
}

sub _get_before_methods {
    my ($package) = @_;

    return
      map { s/^BEFORE_//; $_ }
      grep {m/^BEFORE_(.*)$/} _get_methods($package);
}

sub _get_after_methods {
    my ($package) = @_;

    return
      map { s/^AFTER_//; $_ }
      grep {m/^AFTER_(.*)$/} _get_methods($package);
}

sub _get_around_methods {
    my ($package) = @_;

    return
      map { s/^AROUND_//; $_ }
      grep {m/^AROUND_(.*)$/} _get_methods($package);
}

sub _get_public_methods {
    my ($package) = @_;

    return grep { !m/^(?:_|[A-Z])/ } _get_methods($package);
}

sub _get_methods {
    my ($package) = @_;

    my @methods = ();

    no strict 'refs';
    for (keys %{"$package\::"}) {
        next if /import/;
        push @methods, $_ if defined &{"$package\::$_"};
    }

    return @methods;
}

sub _install_sub {
    my ($package, $name, $sub) = @_;

    no strict 'refs';
    *{$package . '::' . $name} = $sub;
}

sub _delete_sub {
    my ($package, $name) = @_;

    no strict 'refs';
    my $stash = \%{"$package\::"};

    my $ref = \*{"$package\::$name"};

    die "Method '$name' not found in '$package'" unless $ref;

    delete $stash->{$name};

    return $ref;
}

1;
