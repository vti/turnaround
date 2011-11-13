package Lamework::SetupEnv;

use strict;
use warnings;

use base 'Lamework::Base';

use Lamework::Env;
use Lamework::HelperFactory;

sub setup {
    my $self = shift;
    my ($env) = @_;

    $env = Lamework::Env->new($env);

    $env->set(
        vars => {
            helpers => $self->_build_helpers(
                namespace => ref($self->{app}) . '::Helper::'
            )
        }
    );

    return $self;
}

sub _build_helpers {
    my $self = shift;

    return Lamework::HelperFactory->new(@_);
}

1;
