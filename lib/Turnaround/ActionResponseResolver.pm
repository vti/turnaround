package Turnaround::ActionResponseResolver;

use strict;
use warnings;

use Encode ();

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub resolve {
    my $self = shift;
    my ($res) = @_;

    return unless defined $res;

    if (my $ref = ref $res) {
        return $res if $ref eq 'ARRAY' || $ref eq 'CODE';

        return $res->finalize if $res->isa('Turnaround::Response');

        return;
    }

    $res = Encode::encode('UTF-8', $res) if Encode::is_utf8($res);
    return [200, ['Content-Type' => 'text/html'], [$res]];
}

1;
