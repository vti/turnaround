use strict;
use warnings;

use Test::More tests => 18;

use_ok('Lamework::Action');

use Lamework::Routes;
use Lamework::Registry;
use Lamework::Displayer;
use Lamework::Renderer::Caml;

my $routes = Lamework::Routes->new;
$routes->add_route('/:action/:id', name => 'action');

Lamework::Registry->set(routes => $routes);

my $displayer = Lamework::Displayer->new(
    default_format => 'caml',
    formats =>
      {caml => Lamework::Renderer::Caml->new(templates_path => 't/action')}
);

Lamework::Registry->set(displayer => $displayer);

my $match = $routes->match('/action/1');

my $env = {
    HTTP_HOST               => 'localhost',
    QUERY_STRING            => 'foo=bar',
    'lamework.routes.match' => $match
};

my $action = Lamework::Action->new(env => $env);
is $action->captures->{id}    => 1;
is $action->req->param('foo') => 'bar';

is $action->url_for('action', action => 'action', id => 2) =>
  'http://localhost/action/2';
is $action->url_for('http://google.com') => 'http://google.com';
is $action->url_for('/')                 => 'http://localhost/';
is $action->url_for('/foo')              => 'http://localhost/foo';
is $action->url_for('/bar/')             => 'http://localhost/bar/';

$action->redirect('action', action => 'foo', id => 3);
is $action->res->code     => 302;
is $action->res->location => 'http://localhost/foo/3';

$action->redirect('/bar/');
is $action->res->code     => 302;
is $action->res->location => 'http://localhost/bar/';

$action = Lamework::Action->new(env => $env);
$action->render_file('template.caml');
is $action->res->code => 200;
is $action->res->body => 'Hello there!';

$action = Lamework::Action->new(env => $env);
$action->render_forbidden;
is $action->res->code => 403;
is $action->res->body => 'Forbidden!';

$action = Lamework::Action->new(env => $env);
$action->render_not_found;
is $action->res->code => 404;
is $action->res->body => 'Not Found!';

1;
