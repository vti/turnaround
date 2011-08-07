package Lamework::Middleware::MVC;

use strict;
use warnings;

use Lamework::Middleware::ActionBuilder;
use Lamework::Middleware::RequestDispatcher;
use Lamework::Middleware::ViewDisplayer;

sub wrap {
    my $self = shift;
    my ($app, %args) = @_;

    my $app_scope = delete $args{app_scope} or die 'app_scope is required';

    $app =
      $self->_wrap($app, 'ViewDisplayer',
        displayer => $app_scope->get('displayer'));

    $app =
      $self->_wrap($app, 'ActionBuilder',
        action_builder => $app_scope->get('action_builder'));

    $app =
      $self->_wrap($app, 'RequestDispatcher',
        dispatcher => $app_scope->get('dispatcher'));

    return $app;
}

sub _wrap {
    my $self = shift;
    my ($app, $class) = @_;

    $class = "Lamework::Middleware::$class";
    return $class->new({app => $app, @_})->to_app;
}

1;
