package Lamework::Exception;

use strict;
use warnings;

use base 'Lamework::Base';

use overload '""' => sub { $_[0]->to_string }, fallback => 1;

use Encode       ();
use Scalar::Util ();

use Lamework::Loader;

use Exporter qw(import);
our @EXPORT = (qw(throw caught));

sub new {
    my $class = shift;

    my $self = {@_};
    bless $self, $class;

    $self->{message} = 'Exception: ' . ref($self)
      unless defined $self->{message} && $self->{message} ne '';

    return $self;
}

sub path    { $_[0]->{path} }
sub line    { $_[0]->{line} }
sub message { $_[0]->{message} }

sub throw {
    my $class = shift;

    $class ||= __PACKAGE__;

    if (!Lamework::Loader->new->try_load_class($class)) {
        _create_class($class);
    }

    my ($package, $path, $line) = caller;

    unshift @_, 'message' if @_ == 1;
    my $e = $class->new(path => $path, line => $line, @_);

    die $e;
}

sub caught {
    my ($exception, $isa) = @_;

    ($isa, $exception) = ($exception, $_) if @_ < 2;

    $isa ||= 'Lamework::Exception';

    return
      unless defined $exception
          && Scalar::Util::blessed $exception
          && $exception->isa($isa);

    return 1;
}

sub to_string {&as_string}

sub as_string {
    my $self = shift;

    my $message = Encode::encode('UTF-8', $self->{message});

    return sprintf("%s at %s line %s.\n", $message, $self->path, $self->line);
}

sub _create_class {
    my ($class) = @_;

    eval <<"EOF";
package $class;
use base 'Lamework::Exception';
EOF

    return $class;
}

1;
