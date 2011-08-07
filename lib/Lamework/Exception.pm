package Lamework::Exception;

use strict;
use warnings;

use base 'Lamework::Base';

use overload '""' => sub { $_[0]->to_string }, fallback => 1;

require Carp;
use Class::Load;
use Encode ();

sub BUILD {
    my $self = shift;

    $self->{message} = 'Exception: ' . ref($self) unless defined $self->{message};
}

sub message { $_[0]->{message} }

sub throw {
    my $class = shift;

    if (@_ == 1) {
        my $message = shift;

        Carp::croak($class->new(message => $message));
    }
    else {
        my %params = @_;

        if (defined $params{class} && $params{class} !~ s{\+}{}) {
            $params{class} = "$class\::$params{class}";
        }

        if (defined $params{class}) {
            $class = $class->_create_class($params{class});
        }

        Carp::croak($class->new(message => $params{message}));
    }
}

sub to_string { &as_string }
sub as_string { Encode::encode_utf8($_[0]->{message}) }

sub _create_class {
    my $self = shift;
    my ($class) = @_;

    return $class if Class::Load::is_class_loaded($class);

    eval <<"EOF";
package $class;
use base 'Lamework::Exception';
EOF

    return $class;
}

1;
