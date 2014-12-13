use strict;
use warnings;

use Test::More;

use Turnaround::ACL;
use Turnaround::ACL::FromConfig;

subtest 'build acl from config' => sub {
    my $acl = _build_acl()->load('t/acl/acl-from-config/acl.yml');

    ok $acl->is_allowed('anonymous', 'login');
    ok !$acl->is_allowed('anonymous', 'logout');
    ok !$acl->is_allowed('user',      'login');
    ok $acl->is_allowed('user', 'logout');
};

subtest 'do nothing when empty' => sub {
    my $acl = _build_acl()->load('t/acl/acl-from-config/empty.yml');

    ok !$acl->is_allowed('anonymous', 'login');
};

subtest 'accept acl from outside' => sub {
    my $acl = _build_acl(acl => Turnaround::ACL->new)
      ->load('t/acl/acl-from-config/acl.yml');

    ok $acl->is_allowed('anonymous', 'login');
};

sub _build_acl {
    return Turnaround::ACL::FromConfig->new(@_);
}

done_testing;
