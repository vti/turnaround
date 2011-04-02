use strict;
use warnings;

use Test::More tests => 3;

use Plack::Test;
use HTTP::Request::Common;

use lib 't/lib';

use MyApp;

my $app = MyApp->new->psgi_app;

test_psgi $app, sub {
    my $cb = shift;

    my $res = $cb->(GET '/auto');
    is $res->content, "Hello there!";

    $res = $cb->(GET '/custom_response');
    is $res->content, "Custom response!";

    $res = $cb->(GET '/no_action');
    is $res->content, "No action!";
};
