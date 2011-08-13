package Lamework::Middleware::MVC;

use strict;
use warnings;

use Lamework::Middleware::ActionBuilder;
use Lamework::Middleware::RequestDispatcher;
use Lamework::Middleware::ViewDisplayer;

sub wrap {
    my $self = shift;
    my ($app, %args) = @_;

    my $scope = delete $args{scope} or die 'scope is required';

    $app =
      $self->_wrap($app, 'ViewDisplayer',
        displayer => $scope->get('displayer'));

    $app =
      $self->_wrap($app, 'ActionBuilder',
        action_builder => $scope->get('action_builder'));

    $app =
      $self->_wrap($app, 'RequestDispatcher',
        dispatcher => $scope->get('dispatcher'));

    return $app;
}

sub _wrap {
    my $self = shift;
    my ($app, $class) = @_;

    $class = "Lamework::Middleware::$class";
    return $class->new({app => $app, @_})->to_app;
}

1;
