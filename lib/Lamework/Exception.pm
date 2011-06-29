package Lamework::Exception;

use strict;
use warnings;

require Carp;

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
            eval <<"EOF";
package $params{class};
use base 'Lamework::Exception';
EOF
            Carp::croak($params{class}->new(error => $params{error}));
        }
    }
}

1;
