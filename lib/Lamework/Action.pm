package Lamework::Action;

use strict;
use warnings;

use base 'Lamework::Base';

use Lamework::Env;
use Lamework::Exception;
use Lamework::Request;

sub BUILD {
    my $self = shift;

    $self->{env} = Lamework::Env->new($self->{env});
}

sub env {
    my $self = shift;

    return $self->{env};
}

sub req {
    my $self = shift;

    $self->{req} ||= Lamework::Request->new($self->env->to_hash);

    return $self->{req};
}

sub res {
    my $self = shift;

    $self->{res} ||= $self->req->new_response;

    return $self->{res};
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
        my $dispatched_request = $self->env->get('dispatched_request');

        my $path = $dispatched_request->build_path(@_);

        $path =~ s{^/}{};

        $url = $self->req->base;
        $url->path($url->path . $path);
    }

    return $url;
}

sub captures { $_[0]->env->get('dispatched_request')->captures }

sub set_var {
    my $self = shift;

    for (my $i = 0; $i < @_; $i += 2) {
        my $key   = $_[$i];
        my $value = $_[$i + 1];

        $self->env->set("displayer.vars.$key" => $value);
    }

    return $self;
}

sub set_template {
    my $self = shift;
    my ($template) = @_;

    $self->env->set('displayer.template' => $template);

    return $self;
}

sub forbidden {
    my $self = shift;
    my ($message) = @_;

    raise 'Lamework::HTTPException', code => 403, message => $message;
}

sub not_found {
    my $self = shift;
    my ($message) = @_;

    raise 'Lamework::HTTPException', code => 404, message => $message;
}

sub redirect {
    my $self = shift;

    my $url = $self->url_for(@_);

    $self->res->code(302);
    $self->res->header(Location => $url);

    return $self;
}

sub response_cb {
    my $self = shift;

    if (@_) {
        $self->{response_cb} = $_[0];
        return $self;
    }

    return $self->{response_cb};
}

1;
