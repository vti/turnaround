package CustomResponse;

use strict;
use warnings;

use base 'Turnaround::Action';

sub run {
    my $self = shift;

    my $res = $self->new_response(200);
    $res->body('Custom response!');

    return $res;
}

1;
