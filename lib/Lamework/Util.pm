package Lamework::Util;

use strict;
use warnings;

use base 'Exporter';

our @EXPORT = qw(grep_hashref);

sub grep_hashref {
    my ($prefix, $hashref) = @_;

    $prefix = quotemeta $prefix;
    my @keys = grep {m/^$prefix/} keys %$hashref;

    my $args;
    for my $key (@keys) {
        my $value = $hashref->{$key};
        $key =~ s/^$prefix//;

        $args->{$key} = $value;
    }

    return $args;
}

1;
