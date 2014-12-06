use strict;
use warnings;

use Test::More;
use Test::Fatal;
use Test::MonkeyMock;

use Turnaround::ServiceContainer;
use Turnaround::Action;
use Turnaround::Displayer;

subtest 'build_redirect_response' => sub {
    my $action = _build_action();

    my $res = $action->redirect('http://localhost');

    is($res->status,                      302);
    is($res->headers->header('Location'), 'http://localhost');
};

subtest 'build_redirect_response_with_custom_status' => sub {
    my $action = _build_action();

    my $res = $action->redirect('http://localhost', 301);

    is($res->status, 301);
};

subtest 'throw_exception_on_not_found' => sub {
    my $action = _build_action();

    my $e = exception { $action->throw_not_found };

    is($e->code, '404');
};

subtest 'throw_exception_on_forbidden' => sub {
    my $action = _build_action();

    my $e = exception { $action->throw_forbidden };

    is($e->code, '403');
};

subtest 'render_template' => sub {
    my $action = _build_action();

    my $res = $action->render('template');

    is($res, 'template');
};

subtest 'correctly merge template vars' => sub {
    my $displayer = _mock_displayer();
    my $action = _build_action(
        displayer => $displayer,
        env       => {'turnaround.displayer.vars' => {old => 'vars'}}
    );

    my $res = $action->render('template', vars => {foo => 'bar'});

    my ($template, %params) = $displayer->mocked_call_args('render');
    is_deeply \%params, {vars => {foo => 'bar', old => 'vars'}};
};

sub _mock_displayer {
    my $displayer = Turnaround::Displayer->new(renderer => 1);
    $displayer = Test::MonkeyMock->new($displayer);
    $displayer->mock(render => sub { $_[1] });
    return $displayer;
}

sub _build_action {
    my (%params) = @_;

    my $displayer = delete $params{displayer} || _mock_displayer();

    my $services = Turnaround::ServiceContainer->new;
    $services->register(displayer => $displayer);

    my $env = {%{delete $params{env} || {}}, 'turnaround.services' => $services};

    return Turnaround::Action->new(env => $env, %params);
}

done_testing;
