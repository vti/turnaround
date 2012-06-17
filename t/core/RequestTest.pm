package RequestTest;

use strict;
use warnings;
use utf8;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Turnaround::Request;

sub should_handle_utf_in_query_parameters : Test {
    my $self = shift;

    my $req = $self->_build_request({QUERY_STRING => '%E2%99%A5=%E2%99%A5'},
        encoding => 'UTF-8');

    is($req->param('♥'), '♥');
}

sub should_handle_utf_in_multi_query_parameters : Test {
    my $self = shift;

    my $req = $self->_build_request(
        {QUERY_STRING => '%E2%99%A5=%E2%99%A5&%E2%99%A5=b'},
        encoding => 'UTF-8');

    my @params = $req->param('♥');;

    is_deeply(\@params, ['♥', 'b']);
}

sub should_handle_utf_in_post_parameters : Test {
    my $self = shift;

    open my $fh, '<', \'♥=♥';

    my $req = $self->_build_request(
        {   REQUEST_METHOD => 'POST',
            CONTENT_TYPE   => 'application/x-www-form-urlencoded',
            CONTENT_LENGTH => 7,
            'psgi.input'   => $fh
        },
        encoding => 'UTF-8'
    );

    is($req->param('♥'), '♥');
}

sub should_handle_utf_in_multi_post_parameters : Test {
    my $self = shift;

    open my $fh, '<', \'♥=♥&♥=b';

    my $req = $self->_build_request(
        {   REQUEST_METHOD => 'POST',
            CONTENT_TYPE   => 'application/x-www-form-urlencoded',
            CONTENT_LENGTH => 13,
            'psgi.input'   => $fh
        },
        encoding => 'UTF-8'
    );

    my @params = $req->param('♥');;

    is_deeply(\@params, ['♥', 'b']);
}

sub _build_request {
    my $self = shift;

    return Turnaround::Request->new(@_);
}

1;
