package ValidatorTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Turnaround::Validator;

sub validate_empty : Test(1) {
    my $self = shift;

    my $validator = $self->_build_validator;

    ok($validator->validate);
}

sub require_fields : Test(1) {
    my $self = shift;

    my $validator = $self->_build_validator;

    $validator->add_field('foo');

    ok(!$validator->validate);
}

sub require_multiple_fields : Test(1) {
    my $self = shift;

    my $validator = $self->_build_validator;

    $validator->add_field('foo', multiple => 1);

    ok(!$validator->validate({foo => []}));
}

sub empty_values : Test(1) {
    my $self = shift;

    my $validator = $self->_build_validator;

    $validator->add_field('foo');

    ok(!$validator->validate({foo => ''}));
}

sub multiple_empty_values : Test(1) {
    my $self = shift;

    my $validator = $self->_build_validator;

    $validator->add_field('foo', multiple => 1);

    ok(!$validator->validate({foo => ['', '']}));
}

sub only_spaces : Test(1) {
    my $self = shift;

    my $validator = $self->_build_validator;

    $validator->add_field('foo');

    ok(!$validator->validate({foo => " 	\n"}));
}

sub multiple_only_spaces : Test(1) {
    my $self = shift;

    my $validator = $self->_build_validator;

    $validator->add_field('foo', multiple => 1);

    ok(!$validator->validate({foo => [" 	\n", '   ']}));
}

sub set_required_error_to_first_value_from_multiple : Test(1) {
    my $self = shift;

    my $validator = $self->_build_validator;

    $validator->add_field('foo', multiple => 1);

    $validator->validate({foo => []});

    is_deeply($validator->errors, {'foo[0]' => 'REQUIRED', foo => 'REQUIRED'});
}

sub not_valid_rule : Test(1) {
    my $self = shift;

    my $validator = $self->_build_validator;

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    ok(!$validator->validate({foo => 'abc'}));
}

sub valid_rule : Test(1) {
    my $self = shift;

    my $validator = $self->_build_validator;

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    ok($validator->validate({foo => 123}));
}

sub not_return_not_valid_values : Test(1) {
    my $self = shift;

    my $validator = $self->_build_validator;

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    $validator->validate({foo => 'abc'});

    is_deeply($validator->validated_params, {});
}

sub return_valid_values : Test(1) {
    my $self = shift;

    my $validator = $self->_build_validator;

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    $validator->validate({foo => 123});

    is_deeply($validator->validated_params, {foo => 123});
}

sub take_first_value : Test(1) {
    my $self = shift;

    my $validator = $self->_build_validator;

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    $validator->validate({foo => [123, 'bar']});

    is_deeply($validator->validated_params, {foo => 123});
}

sub check_all_values_when_multiple : Test(1) {
    my $self = shift;

    my $validator = $self->_build_validator;

    $validator->add_field('foo', multiple => 1);
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    ok(!$validator->validate({foo => [123, 'bar']}));
}

sub glue_multiple_values : Test(1) {
    my $self = shift;

    my $validator = $self->_build_validator;

    $validator->add_field('foo', multiple => 1);
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    $validator->validate(
        {'foo[0]' => '123', 'foo[1]' => '456', 'foo[2]' => [789, 123]});

    is_deeply($validator->validated_params, {foo => [123, 456, 789]});
}

sub add_only_one_error : Test(1) {
    my $self = shift;

    my $validator = $self->_build_validator;

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    $validator->validate;

    is_deeply($validator->errors, {foo => 'REQUIRED'});
}

sub no_errors_when_field_is_optional : Test(1) {
    my $self = shift;

    my $validator = $self->_build_validator;

    $validator->add_optional_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    ok($validator->validate({foo => ''}));
}

sub leave_optional_empty_values : Test(1) {
    my $self = shift;

    my $validator = $self->_build_validator;

    $validator->add_optional_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    $validator->validate({foo => ''});

    is_deeply($validator->validated_params, {foo => ''});
}

sub leave_optional_multiple_empty_values : Test(1) {
    my $self = shift;

    my $validator = $self->_build_validator;

    $validator->add_optional_field('foo', multiple => 1);
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    $validator->validate({foo => ['', '']});

    is_deeply($validator->validated_params, {foo => ['', '']});
}

sub set_default_message : Test(1) {
    my $self = shift;

    my $validator = $self->_build_validator;

    $validator->add_field('foo');

    $validator->validate;

    is_deeply($validator->errors, {foo => 'REQUIRED'});
}

sub set_global_custom_message : Test(1) {
    my $self = shift;

    my $validator =
      $self->_build_validator(messages => {'REQUIRED' => 'Required'});

    $validator->add_field('foo');

    $validator->validate;

    is_deeply($validator->errors, {foo => 'Required'});
}

sub set_custom_message : Test(1) {
    my $self = shift;

    my $validator = $self->_build_validator(
        messages => {'foo.REQUIRED' => 'Foo is required'});

    $validator->add_field('foo');

    $validator->validate;

    is_deeply($validator->errors, {foo => 'Foo is required'});
}

sub set_rule_default_message : Test(1) {
    my $self = shift;

    my $validator = $self->_build_validator;

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    $validator->validate({foo => 'bar'});

    is_deeply($validator->errors, {foo => 'REGEXP'});
}

sub set_rule_custom_message : Test(1) {
    my $self = shift;

    my $validator = $self->_build_validator;

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/)
      ->set_message('Wrong format');

    $validator->validate({foo => 'bar'});

    is_deeply($validator->errors, {foo => 'Wrong format'});
}

sub validate_group_rule : Test(1) {
    my $self = shift;

    my $validator = $self->_build_validator;

    $validator->add_field('foo');
    $validator->add_field('bar');
    $validator->add_group_rule('fields', [qw/foo bar/], 'compare');

    ok($validator->validate({foo => 'baz', bar => 'baz'}));
}

sub validate_invalid_group_rule : Test(1) {
    my $self = shift;

    my $validator = $self->_build_validator;

    $validator->add_field('foo');
    $validator->add_field('bar');
    $validator->add_group_rule('fields', [qw/foo bar/], 'compare');

    ok(!$validator->validate({foo => 'baz', bar => '123'}));
}

sub set_group_error : Test(1) {
    my $self = shift;

    my $validator = $self->_build_validator;

    $validator->add_field('foo');
    $validator->add_field('bar');
    $validator->add_group_rule('fields', [qw/foo bar/], 'compare');

    $validator->validate({foo => 'baz', bar => '123'});

    is_deeply($validator->errors, {fields => 'COMPARE'});
}

sub _build_validator {
    my $self = shift;

    return Turnaround::Validator->new(@_);
}

1;
