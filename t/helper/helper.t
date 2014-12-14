use strict;
use warnings;

use Test::More;
use Test::MonkeyMock;

use Turnaround::Helper;

subtest 'returns empty hash ref' => sub {
    my $env = {};
    my $helper = _build_helper(env => $env);

    is_deeply $helper->params, {};
};

subtest 'returns params' => sub {
    my $env = {'turnaround.displayer.vars' => {params => {foo => 'bar'}}};
    my $helper = _build_helper(env => $env);

    is_deeply $helper->params, {foo => 'bar'};
};

subtest 'returns param' => sub {
    my $env = {'turnaround.displayer.vars' => {params => {foo => 'bar'}}};
    my $helper = _build_helper(env => $env);

    is_deeply $helper->param('foo'), 'bar';
};

subtest 'returns param if array ref' => sub {
    my $env = {'turnaround.displayer.vars' => {params => {foo => ['bar', 'baz']}}};
    my $helper = _build_helper(env => $env);

    is_deeply $helper->param('foo'), 'bar';
};

subtest 'returns all params when single' => sub {
    my $env = {'turnaround.displayer.vars' => {params => {foo => 'bar'}}};
    my $helper = _build_helper(env => $env);

    is_deeply $helper->param_multi('foo'), ['bar'];
};

subtest 'returns all params when array ref' => sub {
    my $env = {'turnaround.displayer.vars' => {params => {foo => ['bar', 'baz']}}};
    my $helper = _build_helper(env => $env);

    is_deeply $helper->param_multi('foo'), ['bar', 'baz'];
};

subtest 'returns empty arrray ref on multi' => sub {
    my $env = {};
    my $helper = _build_helper(env => $env);

    is_deeply $helper->param_multi('unknown'), [];
};

sub _build_helper { Turnaround::Helper->new(@_) }

done_testing;
