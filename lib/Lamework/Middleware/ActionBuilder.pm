package Lamework::Middleware::ActionBuilder;

use strict;
use warnings;

use base 'Lamework::Middleware';

use Class::Load       ();
use String::CamelCase ();
use Try::Tiny;

use Lamework::Registry;

sub call {
    my $self = shift;
    my ($env) = @_;

    my $res = $self->_action($env);
    return $res if $res;

    return $self->app->($env);
}

sub _action {
    my $self = shift;
    my ($env) = @_;

    my $m = $env->{'lamework.routes.match'};
    return unless $m;

    my $action = $m->params->{action};
    return unless defined $action;

    my $class = $self->_build_class_name($action);

    my $res;
    try {
        Class::Load::load_class($class);

        $action = $class->new(env => $env);
        $action->run;

        if ($action->res->code || defined $action->res->body) {
            $res = $self->_finalize_response($action->res);
        }
    }
    catch {
        die $_ unless $_ =~ m{^Can't locate [^ ]+ in \@INC }
    };

    return $res;
}

sub _build_class_name {
    my $self = shift;
    my ($action) = @_;

    $action = String::CamelCase::camelize($action);

    my $app       = Lamework::Registry->get('app');
    my $namespace = $app->namespace;

    return "$namespace\::Action::$action";
}

sub _finalize_response {
    my $self = shift;
    my ($res) = @_;

    unless (defined $res->content_length) {
        $res->content_length(length $res->body);
    }

    unless ($res->content_type) {
        $res->content_type('text/html');
    }

    return $res->finalize;
}

1;
