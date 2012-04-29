package Turnaround::Response;

use strict;
use warnings;

use base 'Plack::Response';

use Encode ();
use Plack::Util ();

sub finalize {
    my $self = shift;

    unless ($self->content_type) {
        $self->content_type('text/html');
    }

    my $arrayref = $self->SUPER::finalize;

    if (Plack::Util::is_real_fh($arrayref->[2])) {
        # TODO
    }
    elsif (ref $arrayref->[2] eq 'ARRAY') {
        $arrayref->[2] =
          [map { Encode::is_utf8($_) ? Encode::encode('UTF-8', $_) : $_ }
              @{$arrayref->[2]}];
    }
    else {
        # TODO
    }

    return $arrayref;
}

1;
