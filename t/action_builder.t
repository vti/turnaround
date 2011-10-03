use strict;
use warnings;

use Test::Spec;

use lib 't/action_builder';

use_ok('Lamework::ActionBuilder');

describe 'ActionBuilder' => sub {
    my $action_builder;

    before each => sub {
        $action_builder = Lamework::ActionBuilder->new;
    };

    it "should build an action" => sub {
        my $action = $action_builder->build('Foo');
        isa_ok($action, 'Foo');
    };

    it "should die on action syntax errors" => sub {
        eval { $action_builder->build('WithSyntaxErrors'); };
        ok($@);
    };

    it "should die when action dies" => sub {
        eval { $action_builder->build('DieDuringCreation'); };
        ok($@);
    };
};

runtests unless caller;
