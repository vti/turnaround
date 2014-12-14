use strict;
use warnings;

use Test::More;

use Turnaround::Plugins;

use lib 't/plugins_t';

subtest 'run_plugins' => sub {
    my $plugins = _build_plugins();

    $plugins->register_plugin('Plugin');

    my $env = {};
    $plugins->run_plugins($env);

    is $env->{foo}, 'bar';
};

sub _build_plugins { Turnaround::Plugins->new(@_) }

done_testing;
