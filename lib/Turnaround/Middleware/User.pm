package Turnaround::Middleware::User;

use strict;
use warnings;

use base 'Turnaround::Middleware';

use Scalar::Util qw(blessed);

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

use base 'Turnaround::Base';

sub role { 'anonymous' }

1;
