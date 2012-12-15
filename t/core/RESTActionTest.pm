package RESTActionTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Turnaround::RESTAction;

sub get_method_from_params : Test {
    my $self = shift;

    my $action = $self->_build_action(env => {QUERY_STRING => '_method=PUT'});

    my $res = $action->run;

    is_deeply($res, 'PUT');
}

sub fallback_to_request_method : Test {
    my $self = shift;

    my $action = $self->_build_action(env => {REQUEST_METHOD => 'PUT'});

    my $res = $action->run;

    is_deeply($res, 'PUT');
}

sub fallback_to_request_method_if_param_invalid : Test {
    my $self = shift;

    my $action = $self->_build_action(
        env => {
            REQUEST_METHOD => 'PUT',
            QUERY_STRING   => '_method=FOO'
        }
    );

    my $res = $action->run;

    is($res, 'PUT');
}

sub do_nothing_when_no_method_found : Test {
    my $self = shift;

    my $action = $self->_build_action(env => {REQUEST_METHOD => 'HEAD'});

    my $res = $action->run;

    is($res, undef);
}

sub call_catchall_method_when_available : Test {
    my $self = shift;

    my $action = RESTActionAll->new(env => {REQUEST_METHOD => 'HEAD'});

    my $res = $action->run;

    is($res, 'ALL');
}

sub _build_action {
    my $self = shift;

    return RESTAction->new(@_);
}

package RESTAction;
use base 'Turnaround::RESTAction';

sub method_PUT { 'PUT' }

package RESTActionAll;
use base 'Turnaround::RESTAction';

sub method_ALL { 'ALL' }

1;
