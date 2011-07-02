package Lamework::Exception;

use strict;
use warnings;

require Carp;
use Class::Load;

sub new {
    my $class = shift;

    my $self = {@_};
    bless $self, $class;

    return $self;
}

sub error { shift->{error} }

sub throw {
    my $class = shift;

    if (@_ == 1) {
        my $error = shift;

        Carp::croak($class->new(error => $error));
    }
    else {
        my %params = @_;

        unless ($params{class} =~ s{\+}{}) {
            $params{class} = "$class\::$params{class}";
        }

        if ($params{class}) {
            $class->_create_class($params{class});
            Carp::croak($params{class}->new(error => $params{error}));
        }
    }
}

sub _create_class {
    my $self = shift;
    my ($class) = @_;

    return if Class::Load::is_class_loaded($class);

    eval <<"EOF";
package $class;
use base 'Lamework::Exception';
EOF
}

1;
