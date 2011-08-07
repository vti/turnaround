package Lamework::Action;

use strict;
use warnings;

use base 'Lamework::Action::Base';

use Lamework::HTTPException;
use Lamework::Logger;

sub log {
    my $self = shift;

    $self->{logger}
      ||= Lamework::Logger->new(logger => $self->env->{'psgix.logger'});

    return $self->{logger};
}

sub url_for {
    my $self = shift;

    my $url;

    if ($_[0] =~ m{^/}) {
        my $path = $_[0];
        $path =~ s{^/}{};

        $url = $self->req->base;
        $url->path($url->path . $path);
    }
    elsif ($_[0] =~ m{^https?://}) {
        $url = $_[0];
    }
    else {
        my $dispatched_request = $self->env->{'lamework.dispatched_request'};

        my $path = $dispatched_request->build_path(@_);

        $path =~ s{^/}{};

        $url = $self->req->base;
        $url->path($url->path . $path);
    }

    return $url;
}

sub captures { $_[0]->env->{'lamework.dispatched_request'}->captures }

sub set_var {
    my $self = shift;

    for (my $i = 0; $i < @_; $i += 2) {
        my $key   = $_[$i];
        my $value = $_[$i + 1];

        $self->env->{'lamework.displayer'}->{vars}->{$key} = $value;
    }

    return $self;
}

sub vars {
    my $self = shift;

    return $self->env->{'lamework.displayer'}->{vars};
}

sub set_template {
    my $self = shift;
    my ($template) = @_;

    $self->env->{'lamework.displayer'}->{template} = $template;

    return $self;
}

sub set_layout {
    my $self = shift;
    my ($layout) = @_;

    $self->env->{'lamework.displayer'}->{layout} = $layout;

    return $self;
}

sub forbidden {
    my $self = shift;
    my ($message) = @_;

    $message ||= $self->env->{'lamework.ioc'}->get('displayer')
      ->render_file('forbidden');

    Lamework::HTTPException->throw(403, $message);
}

sub not_found {
    my $self = shift;
    my ($message) = @_;

    $message ||= $self->env->{'lamework.ioc'}->get('displayer')
      ->render_file('not_found');

    Lamework::HTTPException->throw(404, $message)
}

sub redirect {
    my $self = shift;

    my $url = $self->url_for(@_);

    Lamework::HTTPException->throw(302, location => $url);
}

1;
