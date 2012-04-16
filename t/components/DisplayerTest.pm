package DisplayerTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Turnaround::Displayer;
use Turnaround::Renderer::Caml;

sub render_template : Test {
    my $self = shift;

    my $d = $self->_build_displayer;

    is($d->render('{{hello}}', vars => {hello => 'there'}) => 'there');
}

sub render_file : Test {
    my $self = shift;

    my $d = $self->_build_displayer;

    is($d->render_file('template.caml', vars => {hello => 'there'}) =>
          'there');
}

sub _build_displayer {
    my $self = shift;

    Turnaround::Displayer->new(renderer =>
          Turnaround::Renderer::Caml->new(templates_path => 't/components/DisplayerTest'));
}

1;
