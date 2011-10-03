package Lamework::Middleware::MVC;

use strict;
use warnings;

use Lamework::Registry;

use Lamework::Middleware::ActionBuilder;
use Lamework::Middleware::RequestDispatcher;
use Lamework::Middleware::ViewDisplayer;

sub wrap {
    my $self = shift;
    my ($app, %args) = @_;

    $app = $self->_wrap($app, 'ViewDisplayer', displayer => $args{displayer});

    $app =
      $self->_wrap($app, 'ActionBuilder',
        action_builder => $args{action_builder});

    $app =
      $self->_wrap($app, 'RequestDispatcher',
        dispatcher => $args{dispatcher});

    return $app;
}

sub _wrap {
    my $self  = shift;
    my $app   = shift;
    my $class = shift;

    $class = "Lamework::Middleware::$class";
    return $class->new({app => $app, @_})->to_app;
}

1;
