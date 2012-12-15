package ActionTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;
use Test::MockObject::Extends;

use Turnaround::ServiceContainer;
use Turnaround::Action;
use Turnaround::Displayer;

sub build_redirect_response : Test(2) {
    my $self = shift;

    my $action = $self->_build_action;

    my $res = $action->redirect('http://localhost');

    is($res->status,                      302);
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

sub render_template : Test {
    my $self = shift;

    my $action = $self->_build_action;

    my $res = $action->render('template');

    is($res, 'template');
}

sub _build_action {
    my $self = shift;

    my $displayer = Turnaround::Displayer->new(renderer => 1);
    $displayer = Test::MockObject::Extends->new($displayer);
    $displayer->mock(render => sub { $_[1] });

    my $services = Turnaround::ServiceContainer->new;
    $services->register(displayer => $displayer);

    my $env = {'turnaround.services' => $services};

    return Turnaround::Action->new(env => $env, @_);
}

1;
