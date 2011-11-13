package DisplayerTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Lamework::Displayer;
use Lamework::Renderer::Caml;

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

    Lamework::Displayer->new(renderer =>
          Lamework::Renderer::Caml->new(templates_path => 't/displayer'));
}

1;
