package DispatcherRoutesTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Turnaround::Dispatcher::Routes;
use Turnaround::Routes;

sub throw_on_unknown_action : Test {
    my $self = shift;

    my $d = $self->_build_dispatcher;

    like(exception { $d->dispatch('/unknown/action') }, qr/action is unknown/i);
}

sub action_from_name : Test {
    my $self = shift;

    my $d = $self->_build_dispatcher;

    my $dispatched = $d->dispatch('/');

    is($dispatched->get_action, 'root');
}

sub action_from_capture : Test {
    my $self = shift;

    my $d = $self->_build_dispatcher;

    my $dispatched = $d->dispatch('/foo');

    is($dispatched->get_action, 'foo');
}

sub undef_on_not_match : Test {
    my $self = shift;

    my $d = $self->_build_dispatcher;

    my $dispatched = $d->dispatch('/foo/bar/baz');

    ok(!$dispatched);
}

sub _build_dispatcher {
    my $self = shift;

    my $routes = Turnaround::Routes->new;
    $routes->add_route('/', name => 'root');
    $routes->add_route('/:action');
    $routes->add_route('/unknown/action');

    Turnaround::Dispatcher::Routes->new(routes => $routes);
}

1;
