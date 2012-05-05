package RESTActionDispatcherTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Turnaround::DispatchedRequest;
use Turnaround::ActionFactory;
use Turnaround::Middleware::RESTActionDispatcher;

sub get_method_from_params : Test {
    my $self = shift;

    my $mw = $self->_build_middleware();

    my $res = $mw->call(
        $self->_build_env(
            action       => 'RESTAction',
            QUERY_STRING => '_method=PUT'
        )
    );

    is_deeply($res->[2], ['PUT']);
}

sub fallback_to_request_method : Test {
    my $self = shift;

    my $mw = $self->_build_middleware();

    my $res = $mw->call(
        $self->_build_env(
            REQUEST_METHOD => 'PUT',
            action         => 'RESTAction',
        )
    );

    is_deeply($res->[2], ['PUT']);
}

sub fallback_to_request_method_if_param_invalid : Test {
    my $self = shift;

    my $mw = $self->_build_middleware();

    my $res = $mw->call(
        $self->_build_env(
            REQUEST_METHOD => 'PUT',
            QUERY_STRING   => '_method=FOO',
            action         => 'RESTAction',
        )
    );

    is_deeply($res->[2], ['PUT']);
}

sub do_nothing_when_no_method_found : Test {
    my $self = shift;

    my $mw = $self->_build_middleware();

    my $res = $mw->call(
        $self->_build_env(
            REQUEST_METHOD => 'HEAD',
            action         => 'RESTAction',
        )
    );

    is_deeply($res->[2], ['OK']);
}

sub call_catchall_method_when_available : Test {
    my $self = shift;

    my $mw = $self->_build_middleware();

    my $res = $mw->call(
        $self->_build_env(
            REQUEST_METHOD => 'HEAD',
            action         => 'RESTActionAll',
        )
    );

    is_deeply($res->[2], ['ALL']);
}

sub _build_middleware {
    my $self = shift;
    my (%params) = @_;

    return Turnaround::Middleware::RESTActionDispatcher->new(
        action_factory => Turnaround::ActionFactory->new(namespace => ''),
        app => sub { [200, [], ['OK']] }
    );
}

sub _build_env {
    my $self = shift;
    my (%params) = @_;

    my $env = {
        REQUEST_METHOD => $params{REQUEST_METHOD} || 'GET',
        QUERY_STRING   => $params{QUERY_STRING}   || '',
        'turnaround.dispatched_request' => Turnaround::DispatchedRequest->new(
            action => delete $params{action}
        )
    };

    return $env;
}

package RESTAction;
use base 'Turnaround::Action';

sub method_PUT { 'PUT' }

package RESTActionAll;
use base 'Turnaround::Action';

sub method_ALL { 'ALL' }

1;
