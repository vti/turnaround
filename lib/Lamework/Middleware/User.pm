package Lamework::Middleware::User;

use strict;
use warnings;

use base 'Lamework::Middleware';

use Scalar::Util qw(blessed);
use Lamework::Env;

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
    if ($session && $session->{user}) {
        my $loader = $self->{user_loader};

        $user =
          blessed $loader
          ? $loader->load($session->{user}, $env)
          : $loader->($session->{user}, $env);
    }

    $user ||= Lamework::Anonymous->new;

    Lamework::Env->new($env)->set(user => $user);
}

package Lamework::Anonymous;

use base 'Lamework::Base';

sub role {'anonymous'}

1;
