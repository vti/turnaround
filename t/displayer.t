use strict;
use warnings;

use Test::More tests => 3;

use_ok('Lamework::Displayer');

use Lamework::Renderer::Caml;

my $r = Lamework::Displayer->new(
    default_format => 'caml',
    formats        => {
        caml => Lamework::Renderer::Caml->new(templates_path => 't/displayer')
    }
);

is($r->render('{{hello}}', vars => {hello => 'there'}) => 'there');

is($r->render_file('template.caml', vars => {hello => 'there'}) => 'there');
