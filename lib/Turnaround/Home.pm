package Turnaround::Home;

use strict;
use warnings;

use overload 'bool' => sub { 1 }, fallback => 1;
use overload '""' => sub { shift->to_string }, fallback => 1;

require Carp;

use Cwd            ();
use File::Basename ();
use File::Spec     ();

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{app_class} = $params{app_class};
    $self->{path}      = $params{path};

    unless (defined $self->{path}) {
        $self->{path} = $self->_detect;
    }

    return $self;
}

sub to_string {
    my $self = shift;

    return $self->{path};
}

sub catfile {
    my $self = shift;

    return ref($self)->new(path => File::Spec->catfile($self->{path}, @_));
}

sub _detect {
    my $self = shift;

    my $home;

    if (defined(my $namespace = $self->{app_class})) {
        $namespace =~ s{::}{/}g;

        if (exists $INC{$namespace . '.pm'}) {
            $home = $INC{$namespace . '.pm'};

            $home = Cwd::realpath(
                File::Spec->catfile(File::Basename::dirname($home), '..'));
        }
        else {
            $home = '.';
        }
    }
    else {
        Carp::croak('Cannot detect home. Pass it manually');
    }

    return $home;
}

1;
