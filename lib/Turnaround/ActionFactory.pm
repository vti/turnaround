package Turnaround::ActionFactory;

use strict;
use warnings;

use base 'Turnaround::Factory';

use Turnaround::Exception;

sub _load_class {
    my $self = shift;

    return eval { $self->SUPER::_load_class(@_) } || do {
        my $e = $@;

        if ($e->does('Turnaround::Exception::ClassNotFound')) {
            raise 'Turnaround::Exception::ActionClassNotFound';
        }

        $e->rethrow;
    };
}

1;
