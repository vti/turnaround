package ACLLoaderTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Turnaround::ACL::Loader;

sub add_acl : Test(4) {
    my $self = shift;

    my $acl =
      $self->_build_acl->load('t/tests/ACLLoaderTest/acl.yml');

    ok($acl->is_allowed('anonymous', 'login'));
    ok(!$acl->is_allowed('anonymous', 'logout'));
    ok(!$acl->is_allowed('user', 'login'));
    ok($acl->is_allowed('user', 'logout'));
}

sub _build_acl {
    my $self = shift;

    return Turnaround::ACL::Loader->new(@_);
}

1;
