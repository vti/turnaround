use strict;
use warnings;

use Test::More;
use Test::MonkeyMock;

use Turnaround::Helper::Displayer;

subtest 'calls displayer' => sub {
    my $displayer = _mock_displayer();
    my $helper = _build_helper(displayer => $displayer);

    $helper->render('template', foo => 'bar');

    my ($template, @vars) = $displayer->mocked_call_args('render');
    is $template, 'template';
    is_deeply \@vars, [layout => undef, vars => {foo => 'bar'}];
};

subtest 'calls displayer with merged vars' => sub {
    my $env = {'turnaround.displayer.vars' => {another => 'var'}};

    my $displayer = _mock_displayer();
    my $helper = _build_helper(displayer => $displayer, env => $env);

    $helper->render('template', foo => 'bar');

    my ($template, @vars) = $displayer->mocked_call_args('render');
    is $template, 'template';
    is_deeply \@vars,
      [layout => undef, vars => {another => 'var', foo => 'bar'}];
};

sub _mock_displayer {
    my $displayer = Test::MonkeyMock->new;
    $displayer->mock(render => sub { '' });
    return $displayer;
}

sub _build_helper {
    my (%params) = @_;
    my $displayer = $params{displayer} || _mock_displayer();

    my $services = Test::MonkeyMock->new;
    $services->mock(service => sub { $displayer });

    Turnaround::Helper::Displayer->new(
        env => $params{env} || {},
        services => $services
    );
}

done_testing;
