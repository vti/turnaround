package Lamework::Middleware::User;

use strict;
use warnings;

use base 'Lamework::Middleware';

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

    if ($session && $session->{user}) {
        my $loader = $self->{user_loader};

        my $user =
          blessed $loader
          ? $loader->load($session->{user})
          : $loader->($session->{user});

        if ($user) {
            $env->{user} = $user;
            return;
        }
    }

    $env->{user} = Lamework::Anonymous->new;
}

package Lamework::Anonymous;

use base 'Lamework::Base';

sub role {'anonymous'}

1;
