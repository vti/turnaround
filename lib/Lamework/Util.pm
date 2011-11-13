package Lamework::Util;

use strict;
use warnings;

use base 'Exporter';

our @EXPORT = qw(merge_hashrefs);

use Storable qw(dclone);

sub merge_hashrefs {
    my (@refs) = @_;

    my $result = dclone(shift @refs);

    foreach my $ref (@refs) {
        foreach my $key (keys %$ref) {
            my $val = $ref->{$key};

            if (exists $result->{$key}) {
                if (ref $result->{$key} ne 'ARRAY') {
                    $result->{$key} = [delete $result->{$key}];
                }

                push @{$result->{$key}},
                    ref $val
                  ? ref $val eq 'ARRAY'
                      ? map { ref $_ ? dclone($_) : $_ } @$val
                      : dclone $val
                  : $val;
            }
            else {
                $result->{$key} = ref $val ? dclone($val) : $val;
            }
        }
    }

    return $result;
}

1;
