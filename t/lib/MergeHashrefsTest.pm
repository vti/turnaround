package MergeHashrefsTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;

use Lamework::Util qw(merge_hashrefs);

sub merge_without_colisions : Test {
    my $self = shift;

    my $hashref = merge_hashrefs({foo => 'bar'}, {bar => 'baz'});

    is_deeply($hashref, {foo => 'bar', bar => 'baz'});
}

sub merge_without_colisions_deep : Test {
    my $self = shift;

    my $hashref = merge_hashrefs({foo => 'bar'}, {bar => [1, 2, 3]});

    is_deeply($hashref, {foo => 'bar', bar => [1, 2, 3]});
}

sub merge_with_colisions_new_arrayref : Test {
    my $self = shift;

    my $hashref = merge_hashrefs({foo => 'bar'}, {foo => 'baz'});

    is_deeply($hashref, {foo => ['bar', 'baz']});
}

sub merge_with_colisions_arrayref : Test {
    my $self = shift;

    my $hashref = merge_hashrefs({foo => ['bar']}, {foo => 'baz'});

    is_deeply($hashref, {foo => ['bar', 'baz']});
}

sub merge_with_colisions_arrayref_symmetric : Test {
    my $self = shift;

    my $hashref = merge_hashrefs({foo => ['bar']}, {foo => ['baz']});

    is_deeply($hashref, {foo => ['bar', 'baz']});
}

1;
