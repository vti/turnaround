package MixinTest;

use strict;
use warnings;

use base 'TestBase';

use lib 't/core/MixinTest';

use Test::More;
use Test::Fatal;

use Foo;
use Turnaround::Mixin;

sub add_public_methods : Test {
    my $self = shift;

    my $foo = Foo->new;

    is($foo->public, 'public');
}

sub leave_old_methods : Test {
    my $self = shift;

    my $foo = Foo->new;

    is($foo->foo, 'foo');
}

sub before_methods : Test(2) {
    my $self = shift;

    my $foo = Foo->new;

    ok(exception { $foo->modified_before('321') });
    is($foo->modified_before, 'before');
}

sub around_methods : Test {
    my $self = shift;

    my $foo = Foo->new;

    is($foo->modified_around('321'), 'before123inner321after');
}

1;
