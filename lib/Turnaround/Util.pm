package Turnaround::Util;

use strict;
use warnings;

use base 'Exporter';

our @EXPORT = qw(slurp);

use Carp qw(croak);
use Encode ();

sub slurp {
    my ($path, $encoding) = @_;

    local $/;
    open my $fh, '<', $path or croak "Can't open $path: $!";

    my $config = <$fh>;

    if (defined($encoding)) {
        $config = Encode::decode($encoding, $config);
    }

    return $config;
}


1;
