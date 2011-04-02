package Lamework::Home;

use strict;
use warnings;

use overload 'bool' => sub {1}, fallback => 1;
use overload '""' => sub { shift->to_string }, fallback => 1;

use File::Spec ();

sub new {
    my $class = shift;
    my ($path) = @_;

    my $self = {path => $path};
    bless $self, $class;

    return $self;
}

sub to_string {
    my $self = shift;

    return $self->{path};
}

sub catfile {
    my $self = shift;

    return File::Spec->catfile($self->{path}, @_);
}

1;
