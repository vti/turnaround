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

    return try {
        Class::Load::load_class($class);

        $action = $class->new(env => $env);
        my $retval = $action->run;

        if (ref $retval eq 'CODE') {
            return $retval;
        }

        if ($action->res->code || defined $action->res->body) {
            return $action->res->finalize;
        }
    }
    catch {
        $class =~ s{::}{/}g;
        die $_ unless $_ =~ m{^Can't locate $class\.pm in \@INC };
        return;
    };
}

sub _build_class_name {
    my $self = shift;
    my ($action) = @_;

    $action = String::CamelCase::camelize($action);

    my $app       = Lamework::Registry->get('app');
    my $namespace = $app->namespace;

    return "$namespace\::Action::$action";
}

1;
