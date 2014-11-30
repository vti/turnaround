use strict;
use warnings;
use utf8;

use Test::More;
use Test::Fatal;

use Turnaround::Config;

subtest 'load_config_based_on_extension' => sub {
    my $config = _build_config();

    my $data = $config->load('t/core/ConfigTest/config.yml');

    is_deeply($data, {foo => 'bar', 'привет' => 'там'});
};

subtest 'load_config_based_on_mode' => sub {
    my $config = _build_config(mode => 1);

    local $ENV{PLACK_ENV} = 'development';

    my $data = $config->load('t/core/ConfigTest/config.yml');

    is_deeply($data, {dev => 1});
};

sub _build_config {
    return Turnaround::Config->new(@_);
}

done_testing;
