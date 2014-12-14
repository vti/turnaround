use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Turnaround::Validator;

subtest 'throws when validated not a hash ref' => sub {
    my $validator = _build_validator();

    like exception { $validator->validate}, qr/must be a hash ref/;
};

subtest 'validates empty' => sub {
    my $validator = _build_validator();

    ok $validator->validate({});
};

subtest 'throws when adding existing field' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');

    like exception { $validator->add_field('foo') }, qr/field 'foo' exists/;
};

subtest 'throws when adding rule to unknown field' => sub {
    my $validator = _build_validator();

    like exception { $validator->add_rule('foo') },
      qr/field 'foo' does not exist/;
};

subtest 'loads rule from custom namespace' => sub {
    my $validator = _build_validator(namespaces => ['Test::']);

    $validator->add_field('foo');
    $validator->add_rule('foo', 'custom');

    ok $validator->validate({foo => 'bar'});
};

subtest 'throws when adding existing rule' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp');

    like exception { $validator->add_rule('foo') }, qr/rule 'foo' exists/;
};

subtest 'throws when adding unknown field to group rule' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');

    like exception { $validator->add_group_rule('rule', [qw/foo bar/]) },
      qr/field 'bar' does not exist/;
};

subtest 'throws when adding existing group rule' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_field('bar');
    $validator->add_group_rule('rule', [qw/foo bar/], 'regexp');

    like exception { $validator->add_group_rule('rule') },
      qr/rule 'rule' exists/;
};

subtest 'require fields' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');

    ok !$validator->validate({});
};

subtest 'require multiple fields' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo', multiple => 1);

    ok(!$validator->validate({foo => []}));
};

subtest 'only one value is required when multiple' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo', multiple => 1);

    ok($validator->validate({foo => ['', 2]}));
};

subtest 'empty values' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');

    ok(!$validator->validate({foo => ''}));
};

subtest 'multiple empty values' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo', multiple => 1);

    ok(!$validator->validate({foo => ['', '']}));
};

subtest 'only spaces' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');

    ok(!$validator->validate({foo => " 	\n"}));
};

subtest 'multiple only spaces' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo', multiple => 1);

    ok(!$validator->validate({foo => [" 	\n", '   ']}));
};

subtest 'set required error to first value from multiple' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo', multiple => 1);

    $validator->validate({foo => []});

    is_deeply($validator->errors, {'foo[0]' => 'REQUIRED', foo => 'REQUIRED'});
};

subtest 'not valid rule' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    ok(!$validator->validate({foo => 'abc'}));
};

subtest 'valid rule' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    ok($validator->validate({foo => 123}));
};

subtest 'not return not valid values' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    $validator->validate({foo => 'abc'});

    is_deeply($validator->validated_params, {});
};

subtest 'return valid values trimmed' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    $validator->validate({foo => ' 123 '});

    is_deeply($validator->validated_params, {foo => 123});
};

subtest 'return valid values not trimmed' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo', trim => 0);

    $validator->validate({foo => ' 123 '});

    is_deeply($validator->validated_params, {foo => ' 123 '});
};

subtest 'return valid values not trimmed when references' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');

    $validator->validate({foo => {}});

    is_deeply($validator->validated_params, {foo => {}});
};

subtest 'return valid values even when not valid' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_field('bar');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    $validator->validate({foo => 123});

    is_deeply($validator->validated_params, {foo => 123});
};

subtest 'take first value' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    $validator->validate({foo => [123, 'bar']});

    is_deeply($validator->validated_params, {foo => 123});
};

subtest 'check all values when multiple' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo', multiple => 1);
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    ok(!$validator->validate({foo => [123, 'bar']}));
};

subtest 'glue multiple values' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo', multiple => 1);
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    $validator->validate(
        {'foo[0]' => '123', 'foo[1]' => '456', 'foo[2]' => [789, 123]});

    is_deeply($validator->validated_params, {foo => [123, 456, 789]});
};

subtest 'add only one error' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    $validator->validate({});

    is_deeply($validator->errors, {foo => 'REQUIRED'});
};

subtest 'no errors when field is optional' => sub {
    my $validator = _build_validator();

    $validator->add_optional_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    ok($validator->validate({foo => ''}));
};

subtest 'leave optional empty values' => sub {
    my $validator = _build_validator();

    $validator->add_optional_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    $validator->validate({foo => ''});

    is_deeply($validator->validated_params, {foo => ''});
};

subtest 'leave optional multiple empty values' => sub {
    my $validator = _build_validator();

    $validator->add_optional_field('foo', multiple => 1);
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    $validator->validate({foo => ['', '']});

    is_deeply($validator->validated_params, {foo => ['', '']});
};

subtest 'set default message' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');

    $validator->validate({});

    is_deeply($validator->errors, {foo => 'REQUIRED'});
};

subtest 'set global custom message' => sub {
    my $validator = _build_validator(messages => {'REQUIRED' => 'Required'});

    $validator->add_field('foo');

    $validator->validate({});

    is_deeply($validator->errors, {foo => 'Required'});
};

subtest 'set rule default message' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    $validator->validate({foo => 'bar'});

    is_deeply($validator->errors, {foo => 'REGEXP'});
};

subtest 'set rule custom message' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/)
      ->set_message('Wrong format');

    $validator->validate({foo => 'bar'});

    is_deeply($validator->errors, {foo => 'Wrong format'});
};

subtest 'validate group rule' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_field('bar');
    $validator->add_group_rule('fields', [qw/foo bar/], 'compare');

    ok($validator->validate({foo => 'baz', bar => 'baz'}));
};

subtest 'validate invalid group rule' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_field('bar');
    $validator->add_group_rule('fields', [qw/foo bar/], 'compare');

    ok(!$validator->validate({foo => 'baz', bar => '123'}));
};

subtest 'set group error' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_field('bar');
    $validator->add_group_rule('fields', [qw/foo bar/], 'compare');

    $validator->validate({foo => 'baz', bar => '123'});

    is_deeply($validator->errors, {fields => 'COMPARE'});
};

subtest 'returns all params' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_field('bar');

    $validator->validate({foo => 'baz', bar => '123'});

    is_deeply $validator->all_params, {foo => 'baz', bar => '123'};
};

subtest 'returns all params preprocessed' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_field('bar', multiple => 1);

    $validator->validate({foo => ['baz'], bar => '123'});

    is_deeply $validator->all_params, {foo => 'baz', bar => ['123']};
};

sub _build_validator {
    return Turnaround::Validator->new(@_);
}

done_testing;

package Test::Custom;
use base 'Turnaround::Validator::Regexp';

sub is_valid {
    my $class = shift;
    my ($value) = @_;

    return 1 if $value eq 'bar';
    return 0;
}

1;
