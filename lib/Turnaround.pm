package Turnaround;

use strict;
use warnings;

use base 'Turnaround::Base';

our $VERSION = '0.1';

use Turnaround::Builder;
use Turnaround::Exception;
use Turnaround::Home;
use Turnaround::Plugins;
use Turnaround::ServiceContainer;

use overload q(&{}) => sub { shift->to_app }, fallback => 1;

sub BUILD {
    my $self = shift;

    my $app_class = ref $self;

    $self->{home} ||= Turnaround::Home->new(app_class => $app_class);
    $self->{builder} ||= Turnaround::Builder->new(
        namespaces => [$app_class . '::Middleware::']);
    $self->{services} ||= Turnaround::ServiceContainer->new;

    $self->{services}->register(
        helpers   => 'Turnaround::HelperFactory',
        lifecycle => 'prototype'
    );

    $self->{plugins} ||= Turnaround::Plugins->new(
        namespaces => [$app_class . '::Plugin::'],
        app_class  => $app_class,
        home       => $self->{home},
        builder    => $self->{builder},
        services   => $self->{services},
    );

    $self->startup;

    return $self;
}

sub home     { $_[0]->{home} }
sub services { $_[0]->{services} }

sub startup  { $_[0] }

sub add_middleware {
    my $self = shift;

    return $self->{builder}->add_middleware(@_);
}

sub register_plugin {
    my $self = shift;

    return $self->{plugins}->register_plugin(@_);
}

sub default_app {
    sub {
        raise 'Turnaround::HTTPException',
          code    => 404,
          message => 'Not Found';
      }
}

sub to_app {
    my $self = shift;

    $self->{psgi_app} ||= do {
        $self->{plugins}->startup_plugins;

        my $app = $self->{builder}->wrap($self->default_app);

        sub {
            my $env = shift;

            $env->{'turnaround.services'} = $self->{services};

            $env->{'turnaround.displayer.vars'}->{'helpers'} =
              $self->{services}->service(
                'helpers',
                namespace    => ref($self) . '::Helper::',
                default_args => {env => $env}
              );

            $self->{plugins}->run_plugins($env);

            $app->($env);
          }
    };

    return $self->{psgi_app};
}

1;
