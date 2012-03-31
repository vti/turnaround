package HTTPExceptionResolverTemplateTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;
use Test::MockObject::Extends;

use Lamework::HTTPException;
use Lamework::Displayer;
use Lamework::HTTPExceptionResolver::Template;

sub should_render_template : Test {
    my $self = shift;

    my $resolver = $self->_build_resolver;

    my $e = $self->_build_exception(code => 404);

    my $res = $resolver->resolve($e, {});

    is_deeply($res,
        [404, ['Content-Type' => 'text/html', 'Content-Length' => 2], ['OK']]
    );
}

sub should_skip_not_exceptions : Test {
    my $self = shift;

    my $resolver = $self->_build_resolver;

    my $var;
    open my $stdout, '>', \$var;
    my $res = $resolver->resolve('died', {'psgi.errors' => $stdout});

    is_deeply($res,
        [500, ['Content-Type' => 'text/html', 'Content-Length' => 21], ['Internal Server Error']]
    );
}

sub _build_exception {
    my $self = shift;

    return Lamework::HTTPException->new(@_);
}

sub _build_resolver {
    my $self = shift;

    my $displayer = Lamework::Displayer->new(renderer => 1);
    $displayer = Test::MockObject::Extends->new($displayer);
    $displayer->mock(render_file => sub {'OK'});

    return Lamework::HTTPExceptionResolver::Template->new(
        displayer => $displayer,
        @_
    );
}

1;
