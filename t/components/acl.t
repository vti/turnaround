use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Turnaround::ACL;

subtest 'denied_by_default' => sub {
    my $acl = _build_acl();

    ok !$acl->is_allowed('admin', 'login');
};

subtest 'allow_allowed_action' => sub {
    my $acl = _build_acl();

    $acl->add_role('admin');
    $acl->allow('admin', 'foo');

    ok $acl->is_allowed('admin', 'foo');
};

subtest 'deny_unknown_role' => sub {
    my $acl = _build_acl();

    ok !$acl->is_allowed('admin', 'foo');
};

subtest 'deny_unknown_action' => sub {
    my $acl = _build_acl();

    $acl->add_role('admin');
    $acl->allow('admin', 'foo');

    ok !$acl->is_allowed('admin', 'bar');
};

subtest 'deny_denied_action' => sub {
    my $acl = _build_acl();

    $acl->add_role('admin');
    $acl->allow('admin', 'foo');
    $acl->deny('admin', 'bar');

    ok !$acl->is_allowed('admin', 'bar');
};

subtest 'allow_everything_with_star' => sub {
    my $acl = _build_acl();

    $acl->add_role('admin');
    $acl->allow('admin', '*');

    ok $acl->is_allowed('admin', 'foo');
};

subtest 'deny_action_despite_of_star' => sub {
    my $acl = _build_acl();

    $acl->add_role('admin');
    $acl->allow('admin', '*');
    $acl->deny('admin', 'foo');

    ok !$acl->is_allowed('admin', 'foo');
};

subtest 'inherit_rules' => sub {
    my $acl = _build_acl();

    $acl->add_role('user');
    $acl->allow('user', 'foo');

    $acl->add_role('admin', 'user');

    ok $acl->is_allowed('admin', 'foo');
};

subtest 'allow_everyone' => sub {
    my $acl = _build_acl();

    $acl->add_role('user1');
    $acl->add_role('user2');
    $acl->allow('*', 'foo');

    ok $acl->is_allowed('user1', 'foo');
    ok $acl->is_allowed('user2', 'foo');
};

subtest 'allow_everyone_everything' => sub {
    my $acl = _build_acl();

    $acl->add_role('user1');
    $acl->add_role('user2');
    $acl->allow('*', '*');

    ok $acl->is_allowed('user1', 'foo');
    ok $acl->is_allowed('user2', 'foo');
};

subtest 'deny_everyone' => sub {
    my $acl = _build_acl();

    $acl->add_role('user1');
    $acl->add_role('user2');
    $acl->allow('*', '*');

    $acl->deny('*', 'foo');

    ok !$acl->is_allowed('user1', 'foo');
    ok !$acl->is_allowed('user2', 'foo');
};

sub _build_acl {
    return Turnaround::ACL->new(@_);
}

done_testing;
