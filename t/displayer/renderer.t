use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Turnaround::Renderer;

subtest 'throws on unimplemented methods' => sub {
    like exception { Turnaround::Renderer->new->render_string },
      qr/Unimplemented/;
    like exception { Turnaround::Renderer->new->render_file },
      qr/Unimplemented/;
};

subtest 'renders string' => sub {
     my $renderer = _build_renderer();

     my (undef, $string) = $renderer->render_string('my template string');

     is $string, 'my template string';
};

subtest 'renders template' => sub {
     my $renderer = _build_renderer();

     my (undef, $path, $template) = $renderer->render_file('template.tpl');

     is $path, 'templates';
     is $template, 'template.tpl';
};

subtest 'renderes templates from overwritten templates_path' => sub {
     my $renderer = _build_renderer(templates_path => 'views');

     my (undef, $path, undef) = $renderer->render_file('template.tpl');

     is $path, 'views';
};

subtest 'prefixes templates path with home' => sub {
     my $renderer = _build_renderer(home => '/root/');

     my (undef, $path, $template) = $renderer->render_file('template.tpl');

     is $path, '/root/templates';
     is $template, 'template.tpl';
};

subtest 'does not prefix templates path with home when absolute' => sub {
     my $renderer = _build_renderer(home => '/root/');

     my (undef, undef, $template) = $renderer->render_file('/path/to/template.tpl');

     is $template, '/path/to/template.tpl';
};

subtest 'does not prefix templates path with anything when absolute' => sub {
     my $renderer = _build_renderer();

     my (undef, undef, $template) = $renderer->render_file('/path/to/template.tpl');

     is $template, '/path/to/template.tpl';
};

subtest 'passes engine arguments' => sub {
     my $renderer = _build_renderer(engine_args => {foo => 'bar'});

     my ($engine) = $renderer->render_file('/path/to/template.tpl');

     is $engine->{foo}, 'bar';
};

sub _build_renderer {
    TestRenderer->new(@_);
}

done_testing;

package TestEngine;
sub new {
    my $class = shift;

    my $self = {@_};
    bless $self, $class;

    return $self;
}

package TestRenderer;
use base 'Turnaround::Renderer';

sub _build_engine {
    shift;
    TestEngine->new(@_);
}

sub render_string {
    my $self = shift;
    return $self->{engine}, @_;
}

sub render_file {
    my $self = shift;
    return $self->{engine}, $self->{templates_path}, @_;
}
