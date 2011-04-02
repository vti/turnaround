package MyApp::Action::Foo;

use strict;
use warnings;

use base 'Lamework::Action';

sub run {
    my $self = shift;

    $self->env->{foo} = 1;
}

1;
