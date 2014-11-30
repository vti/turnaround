package Turnaround::Plugins;

use strict;
use warnings;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{plugins}    = $params{plugins};
    $self->{namespaces} = $params{namespaces};
    $self->{loader}     = $params{loader};

    $self->{app_class} = $params{app_class};
    $self->{services}  = $params{services};
    $self->{builder}   = $params{builder};
    $self->{home}      = $params{home};

    $self->{plugins} = [];
    $self->{namespaces} ||= [];

    $self->{loader} ||=
      Turnaround::Loader->new(
        namespaces => [@{$self->{namespaces}}, qw/Turnaround::Plugin::/]);

    return $self;
}

sub register_plugin {
    my $self = shift;
    my ($plugin, @args) = @_;

    $plugin = $self->{loader}->load_class($plugin);

    my $instance = $plugin->new(
        app_class => $self->{app_class},
        home      => $self->{home},
        services  => $self->{services},
        builder   => $self->{builder},
        @args
    );

    $instance->startup;

    push @{$self->{plugins}}, $instance;

    return $self;
}

sub run_plugins {
    my $self = shift;

    foreach my $plugin (@{$self->{plugins}}) {
        $plugin->run(@_);
    }
}

1;
