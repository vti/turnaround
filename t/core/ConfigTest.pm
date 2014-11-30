package ConfigTest;

use strict;
use warnings;
use utf8;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Turnaround::Config;

sub load_config_based_on_extension : Test {
    my $self = shift;

    my $config = $self->_build_config;

    my $data = $config->load('t/core/ConfigTest/config.yml');

    is_deeply($data, {foo => 'bar', 'привет' => 'там'});
}

sub load_config_based_on_mode : Test {
    my $self = shift;

    my $config = $self->_build_config;

    local $ENV{PLACK_ENV} = 'development';

    my $data = $config->load('t/core/ConfigTest/config.yml');

    is_deeply($data, {dev => 1});
}

sub _build_config {
    my $self = shift;

    return Turnaround::Config->new(@_);
}

1;
