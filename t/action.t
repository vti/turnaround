package Action;

use base 'Lamework::Action';

sub run {}

package main;

use strict;
use warnings;

use Test::More tests => 18;

use_ok('Lamework::Action');

use Lamework::Displayer;
use Lamework::Registry;
use Lamework::Renderer::Caml;
use Lamework::Routes;

my $routes = Lamework::Routes->new;
$routes->add_route('/:action/:id', name => 'action');

Lamework::Registry->set(routes => $routes);

my $displayer = Lamework::Displayer->new(
    default_format => 'caml',
    formats =>
      {caml => Lamework::Renderer::Caml->new(templates_path => 't/action')}
);

Lamework::Registry->set(displayer => $displayer);

my $env = {HTTP_HOST => 'localhost', QUERY_STRING => 'foo=bar'};
my $action = Action->new(env => $env);
is $action->req->param('foo') => 'bar';

is $action->url_for('action', action => 'action', id => 2) =>
  'http://localhost/action/2';
is $action->url_for('http://google.com') => 'http://google.com';
is $action->url_for('/')                 => 'http://localhost/';
is $action->url_for('/foo')              => 'http://localhost/foo';
is $action->url_for('/bar/')             => 'http://localhost/bar/';

eval { $action->redirect('action', action => 'foo', id => 3); };
isa_ok($@, 'Lamework::HTTPException');
is $@->location => 'http://localhost/foo/3';

eval { $action->redirect('/bar/'); };
is $@->location => 'http://localhost/bar/';

$action = Action->new(env => $env);
eval { $action->forbidden };
isa_ok($@, 'Lamework::HTTPException');
is $@->code      => 403;
is $@->as_string => 'Forbidden!';

$action = Action->new(env => $env);
eval { $action->not_found };
isa_ok($@, 'Lamework::HTTPException');
is $@->code      => 404;
is $@->as_string => 'Not Found!';

$action = Action->new(env => $env);
$action->set_var(foo => 'bar');
is_deeply($action->vars, {foo => 'bar'});
$action->set_var(foo => 'bar', bar => 'baz');
is_deeply($action->vars, {foo => 'bar', bar => 'baz'});
