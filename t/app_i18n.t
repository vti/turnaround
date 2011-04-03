use strict;
use warnings;

use Test::More tests => 2;

use Plack::Test;
use HTTP::Request::Common;

use lib 't/lib';

use MyAppI18N;

my $app = MyAppI18N->new->psgi_app;

test_psgi $app, sub {
    my $cb = shift;

    my $res = $cb->(GET '/');
    is $res->content, 'http://localhost/en,en,en|ru';

    $res = $cb->(GET '/ru');
    is $res->content, 'http://localhost/ru,ru,en|ru';
};
