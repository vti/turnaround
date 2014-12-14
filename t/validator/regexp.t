use strict;
use warnings;

use Test::More;

use Turnaround::Validator::Regexp;

subtest 'returns true when matches' => sub {
    my $rule = _build_rule();

    ok $rule->is_valid(1, qr/^\d+$/);
};

subtest 'returns false when not matches' => sub {
    my $rule = _build_rule();

    ok !$rule->is_valid('a1c', qr/^\d+$/);
};

sub _build_rule {
    return Turnaround::Validator::Regexp->new(@_);
}

done_testing;
