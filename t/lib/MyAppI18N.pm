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
        enable '+Lamework::Middleware::I18N', namespace => 'MyAppI18N';

        enable '+Lamework::Middleware::RoutesDispatcher';

        enable '+Lamework::Middleware::ActionBuilder';

        $app;
    };
}

1;
