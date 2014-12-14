use strict;
use warnings;
use utf8;

use Test::More;
use Test::Fatal;

use Turnaround::Config;

subtest 'return empty hash when empty config' => sub {
    my $config = _build_config();

    my $data = $config->load('t/config_t/empty.yml');

    is_deeply($data, {});
};

subtest 'rethrow yaml error' => sub {
    my $config = _build_config();

    like exception { $config->load('t/config_t/error.yml') },
      qr/YAML::Tiny failed to/;
};

subtest 'loads config based on extension' => sub {
    my $config = _build_config();

    my $data = $config->load('t/config_t/config.yml');

    is_deeply($data, {foo => 'bar', 'привет' => 'там'});
};

subtest 'throws when no extension' => sub {
    my $config = _build_config();

    like exception { $config->load('t/config_t/unknown') },
      qr/Can't guess a config format/;
};

subtest 'loads config without mode' => sub {
    my $config = _build_config(mode => 1);

    my $data = $config->load('t/config_t/config.yml');

    is_deeply($data, {foo => 'bar', 'привет' => 'там'});
};

subtest 'loads config with production mode' => sub {
    my $config = _build_config(mode => 1);

    local $ENV{PLACK_ENV} = 'production';

    my $data = $config->load('t/config_t/config.yml');

    is_deeply($data, {foo => 'bar', 'привет' => 'там'});
};

subtest 'loads config based on mode' => sub {
    my $config = _build_config(mode => 1);

    local $ENV{PLACK_ENV} = 'development';

    my $data = $config->load('t/config_t/config.yml');

    is_deeply($data, {dev => 1});
};

subtest 'loads config based on other mode' => sub {
    my $config = _build_config(mode => 1);

    local $ENV{PLACK_ENV} = 'test';

    my $data = $config->load('t/config_t/config.yml');

    is_deeply($data, {test => 'bar'});
};

subtest 'loads config with specified encoding' => sub {
    my $config = _build_config(encoding => 'koi8-r');

    my $data = $config->load('t/config_t/koi8.yml');

    my $bytes = Encode::encode('UTF-8', 'там');
    Encode::from_to($bytes, 'UTF-8', 'koi8-r');
    $bytes = Encode::decode('koi8-r', $bytes);

    is $data->{foo}, $bytes;
};

sub _build_config {
    return Turnaround::Config->new(@_);
}

done_testing;
