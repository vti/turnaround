package Lamework::Env;

use strict;
use warnings;

use base 'Lamework::Base';

use overload
  '%{}'    => sub { $_[0]->to_hash },
  'bool'   => sub { $_[0]->to_hash },
  '""'     => sub { $_[0]->to_hash },
  fallback => 1;

use Scalar::Util qw(weaken isweak);

sub new {
    my $class = shift;
    my ($env) = @_;

    my $self = [{env => $env}];
    bless $self, $class;

    #weaken $self->[0]->{env};

    return $self;
}

sub get { $_[0]->to_hash->{$_[1]} }
sub set { $_[0]->to_hash->{$_[1]} = $_[2] }

sub to_hash { $_[0]->[0]->{env} }

sub captures { $_[0]->get('lamework.captures') || {} }

sub set_captures {
    my $self = shift;
    $self->set('lamework.captures' => {@_});
}

sub match { $_[0]->get('lamework.match') }
sub set_match { $_[0]->set('lamework.match' => $_[1]) }

sub vars {
    my $vars = $_[0]->get('lamework.vars');
    unless (defined $vars) {
        $_[0]->set('lamework.vars' => {});
        return $_[0]->get('lamework.vars');
    }
    return $vars;
}
sub set_var { $_[0]->vars->{$_[1]} = $_[2] }

sub template { $_[0]->get('lamework.template') }
sub set_template { $_[0]->set('lamework.template' => $_[1]) }

1;
