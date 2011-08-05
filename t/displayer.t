use strict;
use warnings;

use Test::More tests => 3;

use_ok('Lamework::Displayer');

use Lamework::Renderer::Caml;

my $d =
  Lamework::Displayer->new(
    renderer => Lamework::Renderer::Caml->new(templates_path => 't/displayer')
  );

is($d->render('{{hello}}', vars => {hello => 'there'}) => 'there');

is($d->render_file('template.caml', vars => {hello => 'there'}) => 'there');
