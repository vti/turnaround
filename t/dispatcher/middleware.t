use strict;
use warnings;
use utf8;

use Test::More;
use Test::Fatal;
use Test::MonkeyMock;

use Turnaround::Routes;
use Turnaround::Dispatcher::Routes;
use Turnaround::Middleware::RequestDispatcher;

subtest 'throws 404 when nothing dispatched' => sub {
    my $mw = _build_middleware();
    my $env = {PATH_INFO => '/', REQUEST_METHOD => 'GET'};

    isa_ok(exception { $mw->call($env) }, 'Turnaround::Exception::HTTP');
};

subtest 'throws 404 when path info is empty' => sub {
    my $mw = _build_middleware();
    my $env = {PATH_INFO => '', REQUEST_METHOD => 'GET'};

    isa_ok(exception { $mw->call($env) }, 'Turnaround::Exception::HTTP');
};

subtest 'dispatches when path found' => sub {
    my $mw = _build_middleware();
    my $env = {PATH_INFO => '/foo', REQUEST_METHOD => 'GET'};

    $mw->call($env);

    ok $env->{'turnaround.dispatched_request'};
};

subtest 'does nothing when method is wrong' => sub {
    my $mw = _build_middleware();
    my $env = {REQUEST_METHOD => 'GET', PATH_INFO => '/only_post'};

    isa_ok(exception { $mw->call($env) }, 'Turnaround::Exception::HTTP');
};

subtest 'dispatches when path and method are found' => sub {
    my $mw = _build_middleware();
    my $env = {REQUEST_METHOD => 'POST', PATH_INFO => '/only_post'};

    $mw->call($env);

    ok $env->{'turnaround.dispatched_request'};
};

subtest 'dispatches utf path' => sub {
    my $mw  = _build_middleware();
    my $env = {
        REQUEST_METHOD => 'GET',
        PATH_INFO      => '/unicode/' . Encode::encode('UTF-8', 'привет')
    };

    $mw->call($env);

    my $dr = $env->{'turnaround.dispatched_request'};
    is $dr->captures->{name}, 'привет';
};

subtest 'dispatches without encoding' => sub {
    my $mw = _build_middleware(encoding => undef);
    my $env = {
        REQUEST_METHOD => 'GET',
        PATH_INFO      => '/unicode/' . Encode::encode('UTF-8', 'привет')
    };

    $mw->call($env);

    my $dr = $env->{'turnaround.dispatched_request'};
    is $dr->captures->{name}, Encode::encode('UTF-8', 'привет');
};

subtest 'loads dispatcher from service container' => sub {
    my $dispatcher =
      Turnaround::Dispatcher::Routes->new(routes => _build_routes());
    my $services = Test::MonkeyMock->new;
    $services->mock(service => sub { $dispatcher });

    my $mw = _build_middleware(dispatcher => undef, services => $services);
    my $env = {
        REQUEST_METHOD => 'GET',
        PATH_INFO      => '/foo'
    };

    $mw->call($env);

    ok $env->{'turnaround.dispatched_request'};
};

subtest 'throws when no dispatcher' => sub {
    my $services = Test::MonkeyMock->new;
    $services->mock(service => sub { });

    like exception {
        _build_middleware(dispatcher => undef, services => $services)
    },
      qr/dispatcher required/;
};

sub _build_routes {
    my $routes = Turnaround::Routes->new;
    $routes->add_route('/foo', defaults => {action => 'foo'});
    $routes->add_route(
        '/only_post',
        defaults => {action => 'bar'},
        method   => 'post'
    );
    $routes->add_route('/unicode/:name', name => 'bar');
    return $routes;
}

sub _build_middleware {
    my $routes = _build_routes();
    return Turnaround::Middleware::RequestDispatcher->new(
        app => sub { [200, [], ['OK']] },
        dispatcher => Turnaround::Dispatcher::Routes->new(routes => $routes),
        @_
    );
}

done_testing;
