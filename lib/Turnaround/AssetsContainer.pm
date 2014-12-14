package Turnaround::AssetsContainer;

use strict;
use warnings;

use Carp qw(croak);
use List::Util qw(first);

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{paths} = [];

    return $self;
}

sub require {
    my $self = shift;
    my ($path, $type) = @_;

    return $self if first { $path eq $_->{path} } @{$self->{paths}};

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

        push @html, $self->_include_type($asset->{type}, $asset->{path});
    }

    return join "\n", @html;
}

sub _include_type {
    my $self = shift;
    my ($type, $path) = @_;

    if ($type eq 'js') {
        return qq|<script src="$path" type="text/javascript"></script>|;
    }
    elsif ($type eq 'css') {
        return qq|<link rel="stylesheet" href="$path" |
          . q|type="text/css" media="screen" />|;
    }
    else {
        croak "unknown asset type '$type'";
    }
}

1;
