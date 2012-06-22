package PluginsTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Turnaround::Plugins;

use lib 't/core/PluginsTest';

sub run_plugins : Test {
    my $self = shift;

    my $plugins = $self->_build_plugins;

    $plugins->register_plugin('Plugin');

    my $env = {};
    $plugins->run_plugins($env);

    is($env->{foo}, 'bar');
}

sub _build_plugins {
    my $self = shift;

    return Turnaround::Plugins->new(@_);
}

1;
