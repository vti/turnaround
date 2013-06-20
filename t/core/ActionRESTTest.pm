package ActionRESTTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Turnaround::Action::REST;

sub build_created_response : Test {
    my $self = shift;

    my $action = $self->_build_action;

    my $res = $action->new_created_response();

    is($res->status, 201);
}

sub throw_exception_on_method_not_allowed : Test {
    my $self = shift;

    my $action = $self->_build_action;

    my $e = exception { $action->throw_method_not_allowed };

    is($e->code, '405');
}

sub _build_action {
    my $self = shift;

    my $env = {};

    return Turnaround::Action::REST->new(env => $env, @_);
}

1;
