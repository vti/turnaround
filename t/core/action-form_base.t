use strict;
use warnings;

use Test::More;
use Turnaround::Test;

subtest 'returns nothing on GET' => sub {
    my $action = _build_action();

    ok !defined $action->run;
};

subtest 'returns nothing on POST with errors' => sub {
    my $action = _build_action(form => {});

    ok !defined $action->run;
};

subtest 'set template var errors' => sub {
    my $action = _build_action(form => {});

    $action->run;

    my $env = $action->env;

    is_deeply $env->{'turnaround.displayer.vars'}->{errors},
      {foo => 'Required'};
};

subtest 'set template var params' => sub {
    my $action = _build_action(form => {bar => 'bar'});

    $action->run;

    my $env = $action->env;

    is_deeply $env->{'turnaround.displayer.vars'}->{params},
      {bar => 'bar', foo => undef};
};

subtest 'call submit on success' => sub {
    my $action = _build_action(form => {foo => '123'});

    my $res = $action->run;

    is $res, 'Submitted';
};

sub _build_action {
    my (%params) = @_;

    my $env = $params{env} || Turnaround::Test->build_env(%params);

    TestAction->new(env => $env);
}

done_testing;

package TestAction;
use base 'Turnaround::Action::FormBase';

sub validator_fields { qw/foo/ }

sub submit { 'Submitted' }
