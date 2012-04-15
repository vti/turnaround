package Lamework;

use strict;
use warnings;

use base 'Lamework::Base';

our $VERSION = '0.1';

use Lamework::Builder;
use Lamework::Exception;
use Lamework::Home;
use Lamework::ServiceContainer;

use overload q(&{}) => sub { shift->to_app }, fallback => 1;

sub BUILD {
    my $self = shift;

    $self->{home} ||= Lamework::Home->new(app_class => ref $self);
    $self->{builder}  ||= Lamework::Builder->new;
    $self->{services} ||= Lamework::ServiceContainer->new;

    $self->startup;

    return $self;
}

sub services { $_[0]->{services} }

sub startup { $_[0] }

sub add_middleware {
    my $self = shift;

    return $self->{builder}->add_middleware(@_);
}

sub default_app {
    sub {
        raise 'Lamework::HTTPException', code => 404, message => 'Not Found';
      }
}

sub to_app {
    my $self = shift;

    $self->{psgi_app} ||= do {
        my $app = $self->{builder}->wrap($self->default_app);

        sub {
            my $env = shift;

            $env->{'lamework.services'} = $self->{services};

            $app->($env);
        }
    };

    return $self->{psgi_app};
}

1;
