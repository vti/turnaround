use strict;
use warnings;
use utf8;

use Test::More;
use Test::Fatal;

use Turnaround::Request;

subtest 'should_handle_utf_in_query_parameters' => sub {
    my $req = _build_request({QUERY_STRING => '%E2%99%A5=%E2%99%A5'},
        encoding => 'UTF-8');

    is($req->param('♥'), '♥');
};

subtest 'should_handle_utf_in_multi_query_parameters' => sub {
    my $req =
      _build_request({QUERY_STRING => '%E2%99%A5=%E2%99%A5&%E2%99%A5=b'},
        encoding => 'UTF-8');

    my @params = $req->param('♥');

    is_deeply(\@params, ['♥', 'b']);
};

subtest 'should_handle_utf_in_post_parameters' => sub {
    my $bytes = Encode::encode('UTF-8', '♥=♥');
    open my $fh, '<', \$bytes;

    my $req = _build_request(
        {
            REQUEST_METHOD => 'POST',
            CONTENT_TYPE   => 'application/x-www-form-urlencoded',
            CONTENT_LENGTH => 7,
            'psgi.input'   => $fh
        },
        encoding => 'UTF-8'
    );

    is($req->param('♥'), '♥');
};

subtest 'should_handle_utf_in_multi_post_parameters' => sub {
    my $bytes = Encode::encode('UTF-8', '♥=♥&♥=b');
    open my $fh, '<', \$bytes;

    my $req = _build_request(
        {
            REQUEST_METHOD => 'POST',
            CONTENT_TYPE   => 'application/x-www-form-urlencoded',
            CONTENT_LENGTH => 13,
            'psgi.input'   => $fh
        },
        encoding => 'UTF-8'
    );

    my @params = $req->param('♥');

    is_deeply(\@params, ['♥', 'b']);
};

sub _build_request {
    return Turnaround::Request->new(@_);
}

done_testing;
