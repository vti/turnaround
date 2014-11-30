use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Turnaround::Dispatcher::Routes;
use Turnaround::Routes;

subtest 'throw_on_unknown_action' => sub {
    my $d = _build_dispatcher();

    like(exception { $d->dispatch('/unknown/action') }, qr/action is unknown/i);
};

subtest 'action_from_name' => sub {
    my $d = _build_dispatcher();

    my $dispatched = $d->dispatch('/');

    is($dispatched->get_action, 'root');
};

subtest 'action_from_capture' => sub {
    my $d = _build_dispatcher();

    my $dispatched = $d->dispatch('/foo');

    is($dispatched->get_action, 'foo');
};

subtest 'build_path' => sub {
    my $d = _build_dispatcher();

    my $dispatched = $d->dispatch('/foo');

    is($dispatched->build_path('root'), '/');
};

subtest 'undef_on_not_match' => sub {
    my $d = _build_dispatcher();

    my $dispatched = $d->dispatch('/foo/bar/baz');

    ok(!$dispatched);
};

sub _build_dispatcher {
    my $routes = Turnaround::Routes->new;
    $routes->add_route('/', name => 'root');
    $routes->add_route('/:action');
    $routes->add_route('/unknown/action');

    Turnaround::Dispatcher::Routes->new(routes => $routes);
}

done_testing;
