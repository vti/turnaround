use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Turnaround::ACL::FromConfig;

subtest 'add_acl' => sub {
    my $acl = _build_acl()->load('t/components/ACLFromConfigTest/acl.yml');

    ok($acl->is_allowed('anonymous', 'login'));
    ok(!$acl->is_allowed('anonymous', 'logout'));
    ok(!$acl->is_allowed('user',      'login'));
    ok($acl->is_allowed('user', 'logout'));
};

sub _build_acl {
    return Turnaround::ACL::FromConfig->new(@_);
}

done_testing;
