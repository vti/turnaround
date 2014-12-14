package Turnaround::AssetsContainer;

use strict;
use warnings;

use Carp qw(croak);

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{paths} = $params{paths};

    $self->{paths} = [];

    return $self;
}

sub require {
    my $self = shift;
    my ($path, $type) = @_;

    return $self if grep { $path eq $_->{path} } @{$self->{paths}};

    ($type) = $path =~ m/\.([^\.]+)$/ unless $type;

    push @{$self->{paths}}, {type => $type, path => $path};

    return $self;
}

sub include {
    my $self = shift;
    my (%params) = @_;

    my @html;
    foreach my $asset (@{$self->{paths}}) {
        next if $params{type} && $asset->{type} ne $params{type};

        if ($asset->{type} eq 'js') {
            push @html,
              qq|<script src="$asset->{path}" type="text/javascript"></script>|;
        }
        elsif ($asset->{type} eq 'css') {
            push @html,
qq|<link rel="stylesheet" href="$asset->{path}" type="text/css" media="screen" />|;
        }
        else {
            croak "unknown asset type '$asset->{type}'";
        }
    }

    return join "\n", @html;
}

1;
