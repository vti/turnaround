package Lamework::Base;

use strict;
use warnings;

use Lamework::Exception ();

sub new {
    my $class = shift;

    my $self = {$class->BUILD_ARGS(@_)};
    bless $self, $class;

    $self->BUILD;

    return $self;
}

sub BUILD_ARGS {
    my $class = shift;

    return @_;
}

sub BUILD {
}

1;
