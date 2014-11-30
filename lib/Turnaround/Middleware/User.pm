package Turnaround::Middleware::User;

use strict;
use warnings;

use base 'Turnaround::Middleware';

use Scalar::Util qw(blessed);

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{user_loader} = $params{user_loader};

    return $self;
}

sub call {
    my $self = shift;
    my ($env) = @_;

    $self->_user($env);

    return $self->app->($env);
}

sub _user {
    my $self = shift;
    my ($env) = @_;

    my $session = $env->{'psgix.session'};

    my $user;
    if ($session) {
        my $loader = $self->{user_loader};

        $user =
          blessed $loader
          ? $loader->load($session, $env)
          : $loader->($session, $env);
    }

    $user ||= Turnaround::Anonymous->new;

    $env->{'turnaround.user'} = $user;
}

package Turnaround::Anonymous;

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub role { 'anonymous' }

1;
