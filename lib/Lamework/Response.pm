package Lamework::Response;

use strict;
use warnings;

use base 'Plack::Response';

use Plack::Util ();

sub finalize {
    my $self = shift;

    unless (defined $self->content_length) {
        my $body = $self->body;

        if (ref $body ne 'ARRAY' && !Plack::Util::is_real_fh($body)) {
            $body = [$body];
        }

        $self->content_length(Plack::Util::content_length($body));
    }

    unless ($self->content_type) {
        $self->content_type('text/html');
    }

    return $self->SUPER::finalize;
}

1;
