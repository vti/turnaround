use strict;
use warnings;

use Test::More tests => 2;

use Plack::Test;
use HTTP::Request::Common;

use lib 't/lib';

my $app = MyAppI18N->new->psgi_app;

test_psgi $app, sub {
    my $cb = shift;

    my $res = $cb->(GET '/');
    is $res->content, 'http://localhost/en';

    $res = $cb->(GET '/ru');
    is $res->content, 'http://localhost/ru';
};

package MyAppI18N;

use base 'Lamework';

use Plack::Builder;

sub startup {
    my $self = shift;

    $self->routes->add_route(
        '/',
        name     => 'foo',
        defaults => {action => 'foo'}
    );
}

sub compile_psgi_app {
    my $self = shift;

    my $app = sub {
        my $env = shift;

        return [404, [], ['404 Not Found']];
    };

    builder {
        enable '+Lamework::Middleware::I18N', languages => [qw/en ru/];

        enable '+Lamework::Middleware::RoutesDispatcher';

        enable '+Lamework::Middleware::ActionBuilder';

        $app;
    };
}

package MyAppI18N::Action::Foo;

use base 'Lamework::Action';

sub run {
    my $self = shift;

    $self->res->code(200);
    $self->res->body($self->url_for('foo'));
}
