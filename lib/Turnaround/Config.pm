package Turnaround::Config;

use strict;
use warnings;

use Carp qw(croak);
use File::Basename ();

use Turnaround::Loader;
use Turnaround::Util qw(slurp);

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{mode}     = $params{mode};
    $self->{encoding} = $params{encoding};

    $self->{encoding} = 'UTF-8' unless exists $params{encoding};

    return $self;
}

sub load {
    my $self = shift;
    my ($path) = @_;

    $path = $self->_change_based_on_mode($path) if $self->{mode};

    my $class = $self->_detect_type($path);

    my $config = slurp($path, $self->{encoding});

    return $class->new->parse($config);
}

sub _change_based_on_mode {
    my $self = shift;
    my ($path) = @_;

    if ((my $mode = $ENV{PLACK_ENV}) && $ENV{PLACK_ENV} ne 'production') {
        $mode = 'dev' if $mode eq 'development';

        $path =~ s{\.([^\.]+)$}{.$mode.$1};
    }

    return $path;
}

sub _detect_type {
    my $self = shift;
    my ($path) = @_;

    my $basename = File::Basename::basename($path);
    my ($ext) = $basename =~ m{\.([^\.]+)$};

    croak q{Can't guess a config format} unless $ext;

    my $class = __PACKAGE__ . '::' . ucfirst($ext);

    Turnaround::Loader->new->load_class($class);

    return $class;
}

1;
