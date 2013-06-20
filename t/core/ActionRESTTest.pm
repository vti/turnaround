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

sub replace_method_from_param : Test {
    my $self = shift;

    my $env = {REQUEST_METHOD => 'POST', QUERY_STRING => '_method=PUT'};
    my $action = $self->_build_action(env => $env);

    is $action->run, 'PUT';
}

sub _build_action {
    my $self = shift;

    my $env = {};

    return ActionRESTTest::Action->new(env => $env, @_);
}

package ActionRESTTest::Action;
use base 'Turnaround::Action::REST';

sub PUT {
    return 'PUT';
}

1;
