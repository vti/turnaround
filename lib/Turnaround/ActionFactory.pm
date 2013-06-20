package Turnaround::ActionFactory;

use strict;
use warnings;

use base 'Turnaround::Factory';

use Scalar::Util qw(blessed);

use Turnaround::Exception::ActionClassNotFound;

sub _load_class {
    my $self = shift;

    return eval { $self->SUPER::_load_class(@_) } || do {
        my $e = $@;

        if (blessed($e) && $e->isa('Turnaround::Exception::ClassNotFound')) {
            Turnaround::Exception::ActionClassNotFound->throw;
        }

        die $e;
    };
}

1;
