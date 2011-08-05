package Lamework::Middleware::MVC;

use strict;
use warnings;

use Lamework::Middleware::ActionBuilder;
use Lamework::Middleware::RequestDispatcher;
use Lamework::Middleware::ViewDisplayer;

sub wrap {
    my $self = shift;
    my ($app, %args) = @_;

    my $ioc = delete $args{ioc} or die 'IOC is required';

    $app = Lamework::Middleware::ViewDisplayer->new(
        {app => $app, displayer => $ioc->get_service('displayer')})->to_app;

    $app = Lamework::Middleware::ActionBuilder->new(
        {   app       => $app,
            namespace => $ioc->get_service('app_class') . '::Action::'
        }
    )->to_app;

    $app = Lamework::Middleware::RequestDispatcher->new(
        {   app        => $app,
            dispatcher => $ioc->get_service('dispatcher')
        }
    )->to_app;

    return $app;
}

1;
