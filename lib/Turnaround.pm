package Turnaround;

use strict;
use warnings;

our $VERSION = '0.1';

use Turnaround::Builder;
use Turnaround::Home;
use Turnaround::Exception::HTTP;
use Turnaround::Plugins;
use Turnaround::ServiceContainer;

use overload q(&{}) => sub { shift->to_app }, fallback => 1;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{home}     = $params{home};
    $self->{builder}  = $params{builder};
    $self->{services} = $params{services};
    $self->{plugins}  = $params{plugins};

    my $app_class = ref $self;

    $self->{home} ||= Turnaround::Home->new(app_class => $app_class);
    if (!ref $self->{home}) {
        $self->{home} = Turnaround::Home->new(path => $self->{home})
    }

    $self->{builder} ||=
      Turnaround::Builder->new(namespaces => [$app_class . '::Middleware::']);
    $self->{services} ||= Turnaround::ServiceContainer->new;

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
sub service { shift->{services}->service(@_) }

sub startup {
    my $self = shift;

    $self->add_middleware(
        'ErrorDocument',
        403        => '/forbidden',
        404        => '/not_found',
        subrequest => 1
    );

    $self->add_middleware('HTTPExceptions');

    $self->add_middleware('RequestDispatcher');
    $self->add_middleware('ActionDispatcher');
    $self->add_middleware('ViewDisplayer');

    $self->register_plugin('DefaultServices');

    return $self;
}

sub add_middleware {
    my $self = shift;
    my ($name, @args) = @_;

    return $self->{builder}
      ->add_middleware($name, services => $self->{services}, @args);
}

sub insert_before_middleware {
    my $self = shift;
    my ($before, $name, @args) = @_;

    return $self->{builder}->insert_before_middleware(
        $before, $name,
        services => $self->{services},
        @args
    );
}

sub register_plugin {
    my $self = shift;

    return $self->{plugins}->register_plugin(@_);
}

sub default_app {
    sub { Turnaround::Exception::HTTP->throw('Not Found', code => 404) }
}

sub to_app {
    my $self = shift;

    $self->{psgi_app} ||= do {
        my $app = $self->{builder}->wrap($self->default_app);

        sub {
            my $env = shift;

            $env->{'turnaround.services'} = $self->{services};

            $self->{plugins}->run_plugins($env);

            $app->($env);
          }
    };

    return $self->{psgi_app};
}

1;
