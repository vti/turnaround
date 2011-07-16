package Lamework::Middleware::ActionBuilder;

use strict;
use warnings;

use base 'Lamework::Middleware';

use Class::Load       ();
use String::CamelCase ();
use Try::Tiny;

sub new {
    my $self = shift->SUPER::new(@_);

    unless (defined $self->{namespace}) {
        $self->{namespace} =
          ref($self->{ioc}->get_service('app')) . '::Action::';
    }

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

    my $captures = $env->{'lamework.captures'};
    return unless $captures;

    my $action = $captures->{action};
    return unless defined $action;

    $action = $self->_build_action($action, $env);
    return unless defined $action;

    my $retval = $action->run;
    return $retval if ref $retval eq 'CODE' || ref $retval eq 'ARRAY';

    if ($action->res->code || defined $action->res->body) {
        return $action->res->finalize;
    }

    return;
}

sub _build_action {
    my $self = shift;
    my ($action, $env) = @_;

    my $class = $self->_build_class_name($action);

    return try {
        Class::Load::load_class($class);

        return $class->new(env => $env);
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

    return "$self->{namespace}$action";
}

1;
