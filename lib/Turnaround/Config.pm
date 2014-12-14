package Turnaround::Config;

use strict;
use warnings;

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

    if ($self->{mode}) {
        if ((my $mode = $ENV{PLACK_ENV}) && $ENV{PLACK_ENV} ne 'production') {
            $mode = 'dev' if $mode eq 'development';

            $path =~ s{\.([^\.]+)$}{.$mode.$1};
        }
    }

    my $basename = File::Basename::basename($path);
    my ($ext) = $basename =~ m{\.([^\.]+)$};

    die "Can't guess a config format" unless $ext;

    my $class = __PACKAGE__ . '::' . ucfirst($ext);

    Turnaround::Loader->new->load_class($class);

    my $config = slurp($path, $self->{encoding});

    return $class->new->parse($config);
}

1;
