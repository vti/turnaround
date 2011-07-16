package Lamework::Config::Ini;

use strict;
use warnings;

use base 'Lamework::Base';

use Config::Tiny;
use String::CamelCase qw(decamelize);

sub load {
    my $self = shift;
    my ($path) = @_;

    if (!defined $path) {
        my $namespace = ref $self->app;
        $path = $self->home->catfile(decamelize($namespace), '.ini');
    }

    return {} unless -f $path;

    return Config::Tiny->read($path);
}

1;
