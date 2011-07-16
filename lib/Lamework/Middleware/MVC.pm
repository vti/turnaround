package Lamework::Middleware::MVC;

use strict;
use warnings;

use Lamework::Middleware::RoutesDispatcher;
use Lamework::Middleware::ActionBuilder;
use Lamework::Middleware::ViewDisplayer;

sub wrap {
    my $self = shift;
    my ($app, %args) = @_;

    my $ioc = delete $args{ioc} or die 'IoC instance is required';

    $app = Lamework::Middleware::ViewDisplayer->new({app => $app})->to_app;

    $app =
      Lamework::Middleware::ActionBuilder->new({app => $app, ioc => $ioc})
      ->to_app;

    $app = Lamework::Middleware::RoutesDispatcher->new({app => $app})->to_app;

    return $app;
}

1;
