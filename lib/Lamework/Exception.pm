package Lamework::Exception;

use strict;
use warnings;

use base 'Lamework::Base';

use overload '""' => sub { $_[0]->to_string }, fallback => 1;

require Carp;
use Class::Load;
use Encode ();

sub message { $_[0]->{message} }

sub throw {
    my $class = shift;

    if (@_ == 1) {
        my $message = shift;

        Carp::croak($class->new(message => $message));
    }
    else {
        my %params = @_;

        unless ($params{class} =~ s{\+}{}) {
            $params{class} = "$class\::$params{class}";
        }

        if ($params{class}) {
            $class->_create_class($params{class});
            Carp::croak($params{class}->new(message => $params{message}));
        }
    }
}

sub to_string { &as_string }
sub as_string { Encode::encode_utf8($_[0]->{message}) }

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
