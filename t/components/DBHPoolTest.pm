package DBHPoolTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

sub SKIP_CLASS {
    return 0 if eval { require DBD::SQLite; 1 };

    warn "Install DBD::SQlite to run this test\n";

    return 1;
}

sub setup : Test(setup) {
    require Turnaround::DBHPool;
}

sub return_handle : Test {
    my $self = shift;

    my $dbh = $self->_build_pool->dbh;

    ok($dbh);
}

sub throw_on_invalid_dsn : Test {
    my $self = shift;

    my $e = exception { $self->_build_pool(dsn => 'foo')->dbh };

    like($e, qr/Can't connect/);
}

sub _build_pool {
    my $self = shift;

    return Turnaround::DBHPool->new(dsn => 'dbi:SQLite:dbname=:memory:', @_);
}

1;
