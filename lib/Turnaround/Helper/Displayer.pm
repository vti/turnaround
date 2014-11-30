package Turnaround::Helper::Displayer;

use strict;
use warnings;

use base 'Turnaround::Helper';

sub render {
    my $self = shift;
    my ($template, @vars) = @_;

    my $env = $self->{env};

    my $vars = {%{$env->{'turnaround.displayer.vars'} || {}}, @vars};

    return $self->service('displayer')
      ->render($template, layout => undef, vars => $vars);
}

1;

