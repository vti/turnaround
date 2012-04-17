package Turnaround::ActionResponseResolver;

use strict;
use warnings;

use base 'Turnaround::Base';

use JSON ();

sub resolve {
    my $self = shift;
    my ($res) = @_;

    return unless defined $res;

    return [200, ['Content-Type' => 'text/html'], [$res]] unless ref $res;

    return $res if ref $res eq 'ARRAY';

    return $res if ref $res eq 'CODE';

    return $self->_to_json($res) if ref $res eq 'HASH';

    return $res->finalize if $res->isa('Turnaround::Response');

    return;
}

sub _to_json {
    my $self = shift;
    my ($json) = @_;

    return [
        200, ['Content-Type' => 'application/json'],
        [JSON::encode_json($json)]
    ];
}

1;
