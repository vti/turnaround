package Turnaround::Exception::Base;

use strict;
use warnings;

use overload
  '""'     => sub { $_[0]->to_string },
  'bool'   => sub { 1 },
  fallback => 1;

use Encode       ();
use Scalar::Util ();

sub new {
    my $class = shift;
    my (%params) = @_;

    if (my $caller = delete $params{caller}) {
        @params{qw/package path line/} = @$caller;
    }

    my $self = {};
    bless $self, $class;

    $self->{message} = $params{message};

    $self->{message} = 'Exception: ' . ref($self)
      unless defined $self->{message} && $self->{message} ne '';

    $self->{message} = ${$self->{message}} if ref $self->{message} eq 'SCALAR';

    return $self;
}

sub path    { $_[0]->{path} }
sub line    { $_[0]->{line} }
sub message { $_[0]->{message} }

sub throw {
    my $class = shift;

    die $class->new(caller => [caller], @_);
}

sub rethrow { die $_[0] }

sub does {
    my $self = shift;
    my (@isas) = @_;

    foreach my $isa (@isas) {
        return 1 if $self->isa($isa);
    }

    return 0;
}

sub to_string { &as_string }

sub as_string {
    my $self = shift;

    my $message = Encode::encode('UTF-8', $self->{message});

    return sprintf("%s at %s line %s.\n", $message, $self->path, $self->line);
}

1;
