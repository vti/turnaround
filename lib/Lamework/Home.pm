package Lamework::Home;

use strict;
use warnings;

use base 'Lamework::Base';

use overload 'bool' => sub {1}, fallback => 1;
use overload '""' => sub { shift->to_string }, fallback => 1;

use Cwd ();
use File::Basename ();
use File::Spec ();
use Scalar::Util qw(blessed);

sub BUILD_ARGS {
    my $class = shift;
    my ($path) = @_;

    if (!defined $path) {
        $path = $class->_detect;
    }

    return (path => $path);
}

sub to_string {
    my $self = shift;

    return $self->{path};
}

sub catfile {
    my $self = shift;

    return File::Spec->catfile($self->{path}, @_);
}

sub _detect {
    my $self = shift;

    my $namespace = ref $self->app;
    $namespace =~ s{::}{/}g;

    my $home = $INC{$namespace . '.pm'};
    if (defined $home) {
        $home = Cwd::realpath(
            File::Spec->catfile(File::Basename::dirname($home), '..'));
    }
    elsif (defined $ENV{LAMEWORK_HOME}) {
        $home = $ENV{LAMEWORK_HOME};
    }
    else {
        die 'Cannot detect home. Pass it manually or set up $ENV{LAMEWORK_HOME}';
    }

    return $home;
}

1;
