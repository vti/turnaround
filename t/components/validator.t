use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Turnaround::Validator;

subtest 'validate_empty' => sub {
    my $validator = _build_validator();

    ok($validator->validate);
};

subtest 'require_fields' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');

    ok(!$validator->validate);
};

subtest 'require_multiple_fields' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo', multiple => 1);

    ok(!$validator->validate({foo => []}));
};

subtest 'only_one_value_is_required_when_multiple' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo', multiple => 1);

    ok($validator->validate({foo => ['', 2]}));
};

subtest 'empty_values' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');

    ok(!$validator->validate({foo => ''}));
};

subtest 'multiple_empty_values' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo', multiple => 1);

    ok(!$validator->validate({foo => ['', '']}));
};

subtest 'only_spaces' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');

    ok(!$validator->validate({foo => " 	\n"}));
};

subtest 'multiple_only_spaces' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo', multiple => 1);

    ok(!$validator->validate({foo => [" 	\n", '   ']}));
};

subtest 'set_required_error_to_first_value_from_multiple' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo', multiple => 1);

    $validator->validate({foo => []});

    is_deeply($validator->errors, {'foo[0]' => 'REQUIRED', foo => 'REQUIRED'});
};

subtest 'not_valid_rule' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    ok(!$validator->validate({foo => 'abc'}));
};

subtest 'valid_rule' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    ok($validator->validate({foo => 123}));
};

subtest 'not_return_not_valid_values' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    $validator->validate({foo => 'abc'});

    is_deeply($validator->validated_params, {});
};

subtest 'return_valid_values_trimmed' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    $validator->validate({foo => ' 123 '});

    is_deeply($validator->validated_params, {foo => 123});
};

subtest 'return_valid_values_not_trimmed' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo', trim => 0);

    $validator->validate({foo => ' 123 '});

    is_deeply($validator->validated_params, {foo => ' 123 '});
};

subtest 'return_valid_values_not_trimmed_when_references' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');

    $validator->validate({foo => {}});

    is_deeply($validator->validated_params, {foo => {}});
};

subtest 'return_valid_values_even_when_not_valid' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_field('bar');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    $validator->validate({foo => 123});

    is_deeply($validator->validated_params, {foo => 123});
};

subtest 'take_first_value' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    $validator->validate({foo => [123, 'bar']});

    is_deeply($validator->validated_params, {foo => 123});
};

subtest 'check_all_values_when_multiple' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo', multiple => 1);
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    ok(!$validator->validate({foo => [123, 'bar']}));
};

subtest 'glue_multiple_values' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo', multiple => 1);
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    $validator->validate(
        {'foo[0]' => '123', 'foo[1]' => '456', 'foo[2]' => [789, 123]});

    is_deeply($validator->validated_params, {foo => [123, 456, 789]});
};

subtest 'add_only_one_error' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    $validator->validate;

    is_deeply($validator->errors, {foo => 'REQUIRED'});
};

subtest 'no_errors_when_field_is_optional' => sub {
    my $validator = _build_validator();

    $validator->add_optional_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    ok($validator->validate({foo => ''}));
};

subtest 'leave_optional_empty_values' => sub {
    my $validator = _build_validator();

    $validator->add_optional_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    $validator->validate({foo => ''});

    is_deeply($validator->validated_params, {foo => ''});
};

subtest 'leave_optional_multiple_empty_values' => sub {
    my $validator = _build_validator();

    $validator->add_optional_field('foo', multiple => 1);
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    $validator->validate({foo => ['', '']});

    is_deeply($validator->validated_params, {foo => ['', '']});
};

subtest 'set_default_message' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');

    $validator->validate;

    is_deeply($validator->errors, {foo => 'REQUIRED'});
};

subtest 'set_global_custom_message' => sub {
    my $validator = _build_validator(messages => {'REQUIRED' => 'Required'});

    $validator->add_field('foo');

    $validator->validate;

    is_deeply($validator->errors, {foo => 'Required'});
};

subtest 'add_global_custom_message' => sub {
    my $validator = _build_validator();
    $validator->add_messages('REQUIRED' => 'Required');

    $validator->add_field('foo');

    $validator->validate;

    is_deeply($validator->errors, {foo => 'Required'});
};

subtest 'set_custom_message' => sub {
    my $validator =
      _build_validator(messages => {'foo.REQUIRED' => 'Foo is required'});

    $validator->add_field('foo');

    $validator->validate;

    is_deeply($validator->errors, {foo => 'Foo is required'});
};

subtest 'set_rule_default_message' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    $validator->validate({foo => 'bar'});

    is_deeply($validator->errors, {foo => 'REGEXP'});
};

subtest 'set_rule_custom_message' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/)
      ->set_message('Wrong format');

    $validator->validate({foo => 'bar'});

    is_deeply($validator->errors, {foo => 'Wrong format'});
};

subtest 'validate_group_rule' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_field('bar');
    $validator->add_group_rule('fields', [qw/foo bar/], 'compare');

    ok($validator->validate({foo => 'baz', bar => 'baz'}));
};

subtest 'validate_invalid_group_rule' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_field('bar');
    $validator->add_group_rule('fields', [qw/foo bar/], 'compare');

    ok(!$validator->validate({foo => 'baz', bar => '123'}));
};

subtest 'set_group_error' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_field('bar');
    $validator->add_group_rule('fields', [qw/foo bar/], 'compare');

    $validator->validate({foo => 'baz', bar => '123'});

    is_deeply($validator->errors, {fields => 'COMPARE'});
};

sub _build_validator {
    return Turnaround::Validator->new(@_);
}

done_testing;
