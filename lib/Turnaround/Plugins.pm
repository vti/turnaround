package Turnaround::Plugins;

use strict;
use warnings;

use base 'Turnaround::Base';

sub BUILD {
    my $self = shift;

    $self->{plugins} = [];
    $self->{namespaces} ||= [];

    $self->{loader} ||=
      Turnaround::Loader->new(
        namespaces => [@{$self->{namespaces}}, qw/Turnaround::Plugin::/]);
}

sub register_plugin {
    my $self = shift;
    my ($plugin, @args) = @_;

    $plugin = $self->{loader}->load_class($plugin);

    my $instance = $plugin->new(
        app_class => $self->{app_class},
        home      => $self->{home},
        builder   => $self->{builder},
        services  => $self->{services},
        @args
    );

    push @{$self->{plugins}}, $instance;

    return $self;
}

sub startup_plugins {
    my $self = shift;

    foreach my $plugin (@{$self->{plugins}}) {
        $plugin->startup;
    }
}

sub run_plugins {
    my $self = shift;

    foreach my $plugin (@{$self->{plugins}}) {
        $plugin->run(@_);
    }
}

1;
