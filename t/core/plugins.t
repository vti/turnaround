use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Turnaround::Plugins;

use lib 't/core/PluginsTest';

subtest 'run_plugins' => sub {
    my $plugins = _build_plugins();

    $plugins->register_plugin('Plugin');

    my $env = {};
    $plugins->run_plugins($env);

    is($env->{foo}, 'bar');
};

sub _build_plugins {
    return Turnaround::Plugins->new(@_);
}

done_testing;
