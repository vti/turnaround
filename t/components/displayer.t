use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Turnaround::Displayer;
use Turnaround::Renderer::Caml;

subtest 'render_template' => sub {
    my $d = _build_displayer();

    is($d->render(\'{{hello}}', vars => {hello => 'there'}) => 'there');
};

subtest 'render_file' => sub {
    my $d = _build_displayer();

    is($d->render('template.caml', vars => {hello => 'there'}) => 'there');
};

subtest 'force_global_layout' => sub {
    my $d = _build_displayer(layout => 'layout.caml');

    is($d->render('template.caml', vars => {hello => 'there'}) =>
          "Before\nthere\nAfter");
};

subtest 'skip_global_layout_when_local_undef' => sub {
    my $d = _build_displayer(layout => 'layout.caml');

    is(
        $d->render(
            'template.caml',
            layout => undef,
            vars   => {hello => 'there'}
        ) => "there"
    );
};

sub _build_displayer {
    Turnaround::Displayer->new(
        renderer => Turnaround::Renderer::Caml->new(
            templates_path => 't/components/DisplayerTest'
        ),
        @_
    );
}

done_testing;
