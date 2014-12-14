use strict;
use warnings;

use Test::More;
use Test::Fatal;
use Test::MonkeyMock;

use Turnaround::ServiceContainer;
use Turnaround::Action;
use Turnaround::Displayer;

subtest 'builds correct redirect response' => sub {
    my $action = _build_action();

    my $res = $action->redirect('http://localhost');

    is($res->status,                      302);
    is($res->headers->header('Location'), 'http://localhost');
};

subtest 'builds redirect response with custom status' => sub {
    my $action = _build_action();

    my $res = $action->redirect('http://localhost', 301);

    is($res->status, 301);
};

subtest 'throws correct not found exception' => sub {
    my $action = _build_action();

    my $e = exception { $action->throw_not_found };

    is($e->code, '404');
};

subtest 'throws correct forbidden exception' => sub {
    my $action = _build_action();

    my $e = exception { $action->throw_forbidden };

    is($e->code, '403');
};

subtest 'throws correct error exception' => sub {
    my $action = _build_action();

    my $e = exception { $action->throw_error };

    is($e->code, '500');
};

subtest 'throws correct error exception with custom status' => sub {
    my $action = _build_action();

    my $e = exception { $action->throw_error('foo', 503) };

    is($e->code, '503');
};

subtest 'renders template' => sub {
    my $action = _build_action();

    my $res = $action->render('template');

    is($res, 'template');
};

subtest 'merges default layout' => sub {
    my $displayer = _mock_displayer();
    my $action    = _build_action(
        displayer => $displayer,
        env       => {'turnaround.displayer.layout' => 'default'}
    );

    my $res = $action->render('template');

    my ($template, %params) = $displayer->mocked_call_args('render');
    is_deeply \%params, {layout => 'default', vars => {}};
};

subtest 'not merges default layout when layout present' => sub {
    my $displayer = _mock_displayer();
    my $action    = _build_action(
        displayer => $displayer,
        env       => {'turnaround.displayer.layout' => 'default'}
    );

    my $res = $action->render('template', layout => 'new');

    my ($template, %params) = $displayer->mocked_call_args('render');
    is_deeply \%params, {layout => 'new', vars => {}};
};

subtest 'not merges default layout even if new is undefined' => sub {
    my $displayer = _mock_displayer();
    my $action    = _build_action(
        displayer => $displayer,
        env       => {'turnaround.displayer.layout' => 'default'}
    );

    my $res = $action->render('template', layout => undef);

    my ($template, %params) = $displayer->mocked_call_args('render');
    is_deeply \%params, {layout => undef, vars => {}};
};

subtest 'correctly merges displayer vars with existing' => sub {
    my $displayer = _mock_displayer();
    my $action    = _build_action(
        displayer => $displayer,
        env       => {'turnaround.displayer.vars' => {old => 'vars'}}
    );

    my $res = $action->render('template', vars => {foo => 'bar'});

    my ($template, %params) = $displayer->mocked_call_args('render');
    is_deeply \%params, {vars => {foo => 'bar', old => 'vars'}};
};

subtest 'url_for returns absolute url as is' => sub {
    my $action = _build_action();

    is $action->url_for('http://foo.com'), 'http://foo.com';
};

subtest 'url_for returns url starting with slash as is' => sub {
    my $action = _build_action(
        env => {PATH_INFO => '/prefix', HTTP_HOST => 'example.com'});

    is $action->url_for('/hello'), 'http://example.com/hello';
};

subtest 'url_for returns url from build_path' => sub {
    my $action = _build_action(env => {HTTP_HOST => 'example.com'});

    is $action->url_for('route'), 'http://example.com/path';
};

subtest 'builds req' => sub {
    my $action = _build_action(env => {PATH_INFO => '/foo'});

    is $action->req->path, '/foo';
};

subtest 'caches req' => sub {
    my $action = _build_action(env => {PATH_INFO => '/foo'});

    my $ref = $action->req;
    is $action->req, $ref;
};

subtest 'throws when no env' => sub {
    my $action = Turnaround::Action->new;

    ok exception { $action->req };
};

subtest 'returns captures from dispatched request' => sub {
    my $action =
      _build_action(dispatched_request =>
          _mock_dispatched_request(captures => {foo => 'bar'}));

    is_deeply $action->captures, {foo => 'bar'};
};

subtest 'sets displayer vars' => sub {
    my $action = _build_action();

    $action->set_var(foo => 'bar');

    is_deeply $action->env->{'turnaround.displayer.vars'}, {foo => 'bar'};
};

sub _mock_displayer {
    my $displayer = Turnaround::Displayer->new(renderer => 1);
    $displayer = Test::MonkeyMock->new($displayer);
    $displayer->mock(render => sub { $_[1] });
    return $displayer;
}

sub _mock_dispatched_request {
    my (%params) = @_;

    my $dr = Test::MonkeyMock->new();
    $dr->mock(build_path => sub { '/path' });
    $dr->mock(captures   => sub { $params{captures} });
    return $dr;
}

sub _build_action {
    my (%params) = @_;

    my $displayer = delete $params{displayer} || _mock_displayer();
    my $dispatched_request =
      delete $params{dispatched_request} || _mock_dispatched_request();

    my $services = Turnaround::ServiceContainer->new;
    $services->register(displayer => $displayer);

    my $env = {
        %{delete $params{env} || {}},
        'turnaround.services'           => $services,
        'turnaround.dispatched_request' => $dispatched_request
    };

    return Turnaround::Action->new(env => $env, %params);
}

done_testing;
