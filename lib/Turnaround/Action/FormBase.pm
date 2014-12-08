package Turnaround::Action::FormBase;

use strict;
use warnings;

use base 'Turnaround::Action';

use Turnaround::Validator;

sub new {
    my $self = shift->SUPER::new(@_);

    $self->{validator} = $self->_build_validator;

    my @fields = $self->validator_fields;
    foreach my $field (@fields) {
        $self->{validator}->add_field($field);
    }

    my @optional_fields = $self->validator_optional_fields;
    foreach my $field (@optional_fields) {
        $self->{validator}->add_optional_field($field);
    }

    return $self;
}

sub validator_fields          { () }
sub validator_optional_fields { () }

sub validator_messages { {} }

sub run {
    my $self = shift;

    if ($self->req->method eq 'GET') {
        return $self->show;
    }

    if ($self->validate) {
        return $self->submit($self->validated_params);
    }

    $self->set_var(errors => $self->{validator}->errors);
    $self->set_var(params => $self->{validator}->all_params);

    return;
}

sub validate {
    my $self = shift;

    my $params = $self->req->parameters->as_hashref_mixed;
    return $self->{validator}->validate($params);
}

sub validated_params {
    my $self = shift;

    return $self->{validator}->validated_params;
}

sub add_validator_error {
    my $self = shift;
    my ($key, $value) = @_;

    $self->{validator}->add_error($key => $value);

    return $self;
}

sub show   { }
sub submit { }

sub _build_validator {
    my $self = shift;

    $self->{validator} = Turnaround::Validator->new(
        namespaces => ['Turnaround::Validator::'],
        messages   => {
            REQUIRED => 'Required',
            %{$self->validator_messages}
        },
        @_
    );
}

1;
