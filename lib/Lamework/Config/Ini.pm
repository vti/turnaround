package Lamework::Config::Ini;

use strict;
use warnings;

use base 'Lamework::Base';

use Config::Tiny;
use String::CamelCase qw(decamelize);

use Lamework::Registry;

sub load {
    my $self = shift;
    my ($path) = @_;

    if (!defined $path) {
        my $namespace = ref Lamework::Registry->get('app');
        my $home = Lamework::Registry->get('home');

        $path = $home->catfile(decamelize($namespace), '.ini');
    }

    return {} unless -f $path;

    return Config::Tiny->read($path);
}

1;
