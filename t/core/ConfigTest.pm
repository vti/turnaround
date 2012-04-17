package ConfigTest;

use strict;
use warnings;

use base 'TestBase';

use utf8;

use Test::More;
use Test::Fatal;

use Turnaround::Config;

sub load_config_base_on_extension : Test {
    my $self = shift;

    my $config = $self->_build_config;

    my $data = $config->load('t/core/ConfigTest/config.yml');

    is_deeply($data, {foo => 'bar', 'привет' => 'там'});
}

sub _build_config {
    my $self = shift;

    return Turnaround::Config->new(@_);
}

1;
