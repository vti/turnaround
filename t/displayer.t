use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Turnaround::Displayer;
use Turnaround::Renderer::Caml;

subtest 'throws when no renderer' => sub {
    like exception { _build_displayer(renderer => undef) },
      qr/renderer required/;
};

subtest 'renders template' => sub {
    my $d = _build_displayer();

    is($d->render(\'{{hello}}', vars => {hello => 'there'}) => 'there');
};

subtest 'renders template without vars' => sub {
    my $d = _build_displayer();

    is($d->render(\'{{hello}}') => '');
};

subtest 'renders file' => sub {
    my $d = _build_displayer();

    is($d->render('template.caml', vars => {hello => 'there'}) => 'there');
};

subtest 'forces global layout' => sub {
    my $d = _build_displayer(layout => 'layout.caml');

    is($d->render('template.caml', vars => {hello => 'there'}) =>
          "Before\nthere\nAfter");
};

subtest 'skips global layout when local undef' => sub {
    my $d = _build_displayer(layout => 'layout.caml');

    is(
        $d->render(
            'template.caml',
            layout => undef,
            vars   => {hello => 'there'}
        ) => "there"
    );
};

subtest 'uses local layout' => sub {
    my $d = _build_displayer(layout => 'layout.caml');

    is(
        $d->render(
            'template.caml',
            layout => 'layout.caml',
            vars   => {hello => 'there'}
        ) => "Before\nthere\nAfter"
    );
};

sub _build_displayer {
    Turnaround::Displayer->new(
        renderer => Turnaround::Renderer::Caml->new(
            templates_path => 't/displayer_t/'
        ),
        @_
    );
}

done_testing;
