package Lamework::Middleware::ActionBuilder;

use strict;
use warnings;

use base 'Lamework::Middleware';

use Class::Load       ();
use String::CamelCase ();
use Try::Tiny;

use Lamework::Action;
use Lamework::Registry;

sub new {
    my $self = shift->SUPER::new(@_);

    $self->{namespace} ||= do {
        my $app       = Lamework::Registry->get('app');
        my $namespace = $app->namespace;
        "$namespace\::Action::";
    };

    $self->{action_class} ||= 'Lamework::Action';

    Class::Load::load_class($self->{action_class});

    return $self;
}

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

    $action = $self->_build_action($action, $env);
    return unless defined $action;

    my $retval = $action->run;
    return $retval if ref $retval eq 'CODE';
    return $retval if ref $retval eq 'ARRAY';

    if ($action->res->code || defined $action->res->body) {
        return $action->res->finalize;
    }

    return;
}

sub _build_action {
    my $self = shift;
    my ($action, $env) = @_;

    if (ref $action eq 'CODE') {
        return $self->{action_class}->new(env => $env, cb => $action);
    }

    my $class = $self->_build_class_name($action);

    return try {
        Class::Load::load_class($class);

        return $class->new(env => $env);
    }
    catch {
        $class =~ s{::}{/}g;

        die $_ unless $_ =~ m{^Can't locate $class\.pm in \@INC };

        return;
    }
}

sub _build_class_name {
    my $self = shift;
    my ($action) = @_;

    $action = String::CamelCase::camelize($action);

    return "$self->{namespace}$action";
}

1;
