use strict;
use warnings;
use utf8;

use Test::More;
use Test::Fatal;

use Turnaround::Routes;
use Turnaround::Dispatcher::Routes;
use Turnaround::Middleware::RequestDispatcher;

subtest 'throw_404_when_nothing_dispatched' => sub {
    my $mw = _build_middleware();
    my $env = {PATH_INFO => '/', REQUEST_METHOD => 'GET'};

    isa_ok(exception { $mw->call($env) }, 'Turnaround::Exception::HTTP');
};

subtest 'throw_404_when_path_info_is_empty' => sub {
    my $mw = _build_middleware();
    my $env = {PATH_INFO => '', REQUEST_METHOD => 'GET'};

    isa_ok(exception { $mw->call($env) }, 'Turnaround::Exception::HTTP');
};

subtest 'dispatch_when_path_found' => sub {
    my $mw = _build_middleware();
    my $env = {PATH_INFO => '/foo', REQUEST_METHOD => 'GET'};

    $mw->call($env);

    ok($env->{'turnaround.dispatched_request'});
};

subtest 'do_nothing_when_method_is_wrong' => sub {
    my $mw = _build_middleware();
    my $env = {REQUEST_METHOD => 'GET', PATH_INFO => '/only_post'};

    isa_ok(exception { $mw->call($env) }, 'Turnaround::Exception::HTTP');
};

subtest 'dispatch_when_path_and_method_are_found' => sub {
    my $mw = _build_middleware();
    my $env = {REQUEST_METHOD => 'POST', PATH_INFO => '/only_post'};

    $mw->call($env);

    ok($env->{'turnaround.dispatched_request'});
};

subtest 'dispatch_utf_path' => sub {
    my $mw  = _build_middleware();
    my $env = {
        REQUEST_METHOD => 'GET',
        PATH_INFO      => '/unicode/' . Encode::encode('UTF-8', 'привет')
    };

    $mw->call($env);

    is($env->{'turnaround.dispatched_request'}->{captures}->{name},
        'привет');
};

sub _build_middleware {
    my $routes = Turnaround::Routes->new;
    $routes->add_route('/foo', defaults => {action => 'foo'});
    $routes->add_route(
        '/only_post',
        defaults => {action => 'bar'},
        method   => 'post'
    );
    $routes->add_route('/unicode/:name', name => 'bar');

    return Turnaround::Middleware::RequestDispatcher->new(
        app => sub { [200, [], ['OK']] },
        dispatcher => Turnaround::Dispatcher::Routes->new(routes => $routes)
    );
}

done_testing;
