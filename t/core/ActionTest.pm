package ActionTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Turnaround::Action;

sub build_redirect_response : Test(2) {
    my $self = shift;

    my $action = $self->_build_action;

    my $res = $action->redirect('http://localhost');

    is($res->status, 302);
    is($res->headers->header('Location'), 'http://localhost');
}

sub build_redirect_response_with_custom_status : Test {
    my $self = shift;

    my $action = $self->_build_action;

    my $res = $action->redirect('http://localhost', 301);

    is($res->status, 301);
}

sub throw_exception_on_not_found : Test {
    my $self = shift;

    my $action = $self->_build_action;

    my $e = exception { $action->not_found };

    is($e->code, '404');
}

sub throw_exception_on_forbidden : Test {
    my $self = shift;

    my $action = $self->_build_action;

    my $e = exception { $action->forbidden };

    is($e->code, '403');
}

sub _build_action {
    my $self = shift;

    my $env = {};

    return Turnaround::Action->new(env => $env, @_);
}

1;
