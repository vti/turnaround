use strict;
use warnings;

use Test::More;

use Turnaround::Util qw(merge_hashrefs);

subtest 'merge_without_colisions' => sub {
    my $hashref = merge_hashrefs({foo => 'bar'}, {bar => 'baz'});

    is_deeply($hashref, {foo => 'bar', bar => 'baz'});
};

subtest 'merge_without_colisions_deep' => sub {
    my $hashref = merge_hashrefs({foo => 'bar'}, {bar => [1, 2, 3]});

    is_deeply($hashref, {foo => 'bar', bar => [1, 2, 3]});
};

subtest 'merge_with_colisions_new_arrayref' => sub {
    my $hashref = merge_hashrefs({foo => 'bar'}, {foo => 'baz'});

    is_deeply($hashref, {foo => ['bar', 'baz']});
};

subtest 'merge_with_colisions_arrayref' => sub {
    my $hashref = merge_hashrefs({foo => ['bar']}, {foo => 'baz'});

    is_deeply($hashref, {foo => ['bar', 'baz']});
};

subtest 'merge_with_colisions_arrayref_symmetric' => sub {
    my $hashref = merge_hashrefs({foo => ['bar']}, {foo => ['baz']});

    is_deeply($hashref, {foo => ['bar', 'baz']});
};

done_testing;
