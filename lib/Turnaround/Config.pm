package Turnaround::Config;

use strict;
use warnings;

use base 'Turnaround::Base';

use File::Basename ();
use Encode ();

use Turnaround::Loader;

our $CONFIG = {};

sub BUILD {
    my $self = shift;

    $self->{encoding} ||= 'UTF-8';
}

sub load {
    my $self = shift;
    my ($path) = @_;

    my $basename = File::Basename::basename($path);
    my ($ext) = $basename =~ m{\.([^\.]+)$};

    die "Can't guess a config format" unless $ext;

    my $class = __PACKAGE__ . '::' . ucfirst($ext);

    Turnaround::Loader->new->load_class($class);

    my $config = $self->_read_file($path);

    if (my $preprocess = $self->{preprocess}) {
        foreach my $key (keys %{$preprocess}) {
            $config =~ s/$key/$preprocess->{$key}/msg;
        }
    }

    return $CONFIG = $class->new->parse($config);
}

sub config { $CONFIG }

sub _read_file {
    my $self = shift;
    my ($path) = @_;

    local $/;
    open my $fh, '<', $path or die "Can't open $path: $!";

    my $config = <$fh>;

    if (my $encoding = $self->{encoding}) {
        $config = Encode::decode($encoding, $config);
    }

    return $config;
}

1;
