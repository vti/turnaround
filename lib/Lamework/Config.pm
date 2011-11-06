package Lamework::Config;

use strict;
use warnings;

use base 'Lamework::Base';

use Class::Load    ();
use File::Basename ();
use Encode ();

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

    Class::Load::load_class($class);

    my $config = $self->_read_file($path);

    return $class->new->parse($config);
}

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
