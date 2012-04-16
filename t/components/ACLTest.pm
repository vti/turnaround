package ACLTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Turnaround::ACL;

sub denied_by_default : Test {
    my $self = shift;

    my $acl = $self->_build_acl;

    ok !$acl->is_allowed('admin', 'login');
}

sub allow_allowed_action : Test {
    my $self = shift;

    my $acl = $self->_build_acl;

    $acl->add_role('admin');
    $acl->allow('admin', 'foo');

    ok $acl->is_allowed('admin', 'foo');
}

sub deny_unknown_role : Test {
    my $self = shift;

    my $acl = $self->_build_acl;

    ok !$acl->is_allowed('admin', 'foo');
}

sub deny_unknown_action : Test {
    my $self = shift;

    my $acl = $self->_build_acl;

    $acl->add_role('admin');
    $acl->allow('admin', 'foo');

    ok !$acl->is_allowed('admin', 'bar');
}

sub deny_denied_action : Test {
    my $self = shift;

    my $acl = $self->_build_acl;

    $acl->add_role('admin');
    $acl->allow('admin', 'foo');
    $acl->deny('admin', 'bar');

    ok !$acl->is_allowed('admin', 'bar');
}

sub allow_everything_with_star : Test {
    my $self = shift;

    my $acl = $self->_build_acl;

    $acl->add_role('admin');
    $acl->allow('admin', '*');

    ok $acl->is_allowed('admin', 'foo');
}

sub deny_action_despite_of_star : Test {
    my $self = shift;

    my $acl = $self->_build_acl;

    $acl->add_role('admin');
    $acl->allow('admin', '*');
    $acl->deny('admin', 'foo');

    ok !$acl->is_allowed('admin', 'foo');
}

sub inherit_rules : Test {
    my $self = shift;

    my $acl = $self->_build_acl;

    $acl->add_role('user');
    $acl->allow('user', 'foo');

    $acl->add_role('admin', 'user');

    ok $acl->is_allowed('admin', 'foo');
}

sub _build_acl {
    my $self = shift;

    return Turnaround::ACL->new(@_);
}

1;
