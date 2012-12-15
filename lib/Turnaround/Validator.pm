package Turnaround::Validator;

use strict;
use warnings;

use Turnaround::Loader;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{messages}   = $params{messages};
    $self->{namespaces} = $params{namespaces};

    $self->{messages}   ||= {};
    $self->{namespaces} ||= ['Turnaround::Validator::'];

    $self->{fields} = {};
    $self->{rules}  = {};
    $self->{errors} = {};
    $self->{values} = {};

    return $self;
}

sub set_messages {
    my $self = shift;
    my $messages = @_ == 1 ? $_[0] : {@_};

    $self->{messages} = $messages;

    return $self;
}

sub add_messages {
    my $self = shift;
    my $messages = @_ == 1 ? $_[0] : {@_};

    $self->{messages} = {%{$self->{messages}}, %$messages};

    return $self;
}

sub get_messages {
    my $self = shift;

    return $self->{messages};
}

sub clear_messages {
    my $self = shift;

    delete $self->{messages};

    return $self;
}

sub field_names {
    my $self = shift;

    return sort keys %{$self->{fields}};
}

sub add_field {
    my $self = shift;
    my ($field, @args) = @_;

    die "Field name '$field' is not unique"
      if exists $self->{fields}->{$field};

    $self->{fields}->{$field} = {required => 1, @args};

    return $self;
}

sub add_optional_field { shift->add_field(@_, required => 0) }

sub add_rule {
    my $self = shift;
    my ($field_name, $rule_name, @rule_args) = @_;

    die "Unknown field '$field_name'"
      unless exists $self->{fields}->{$field_name};

    die "Rule name '$field_name' is not unique"
      if exists $self->{rules}->{$field_name};

    my $rule = $self->_build_rule(
        $rule_name,
        fields => [$field_name],
        args   => \@rule_args
    );

    $self->{rules}->{$field_name} = $rule;

    return $rule;
}

sub add_group_rule {
    my $self = shift;
    my ($group_name, $fields_names, $rule_name, @rule_args) = @_;

    die "Rule name '$group_name' is not unique"
      if exists $self->{rules}->{$group_name};

    my $rule = $self->_build_rule(
        $rule_name,
        fields => $fields_names,
        args   => \@rule_args
    );

    $self->{rules}->{$group_name} = $rule;

    return $self;
}

sub add_error {
    my $self = shift;
    my ($name, $error) = @_;

    for ("$name.$error", $error) {
        if (exists $self->{messages}->{$_}) {
            $error = $self->{messages}->{$_};
            last;
        }
    }

    if ($self->{fields}->{$name}->{multiple}) {
        $self->{errors}->{$name . '[0]'} = $error;
    }

    $self->{errors}->{$name} = $error;
}

sub errors {
    my $self = shift;

    return $self->{errors};
}

sub has_errors {
    my $self = shift;

    return !!%{$self->{errors}};
}

sub validate {
    my $self = shift;
    my ($params) = @_;

    $params = $self->{params} = $self->_prepare_params($params);

    foreach my $name (keys %{$self->{fields}}) {
        my $value = $params->{$name};

        my $is_empty = $self->_is_field_empty($value);

        if ($self->{fields}->{$name}->{required} && $is_empty) {
            $self->add_error($name => 'REQUIRED');
        }
    }

    foreach my $rule_name (keys %{$self->{rules}}) {
        next if exists $self->{errors}->{$rule_name};

        if (exists $self->{fields}->{$rule_name}) {
            next if $self->_is_field_empty($params->{$rule_name});
        }

        my $rule = $self->{rules}->{$rule_name};

        next if $rule->validate($params);

        $self->add_error($rule_name => $rule->get_message);
    }

    $self->{validated_params} = {};

    foreach my $name (keys %{$self->{fields}}) {
        next if exists $self->{errors}->{$name};

        $self->{validated_params}->{$name} = $params->{$name};
    }

    return 0 if $self->has_errors;

    return 1;
}

sub validated_params {
    my $self = shift;

    return $self->{validated_params};
}

sub all_params {
    my $self = shift;

    return $self->{params};
}

sub _is_field_empty {
    my $self = shift;
    my ($value) = @_;

    $value = [$value] unless ref $value eq 'ARRAY';
    return 1 unless @$value;

    my $all_empty = 1;

    foreach (@$value) {
        if (defined $_ && $_ ne '') {
            $all_empty = 0;
            last;
        }
    }

    return $all_empty;
}

sub _prepare_params {
    my $self = shift;
    my ($params) = @_ == 1 ? $_[0] : {@_};

    $params ||= {};
    die 'Must be a hashref' unless ref $params eq 'HASH';

    foreach my $key (keys %$params) {
        next unless $key =~ m/^(.*?)\[(\d+)\]$/;

        my ($name, $index) = ($1, $2);

        my $value = delete $params->{$key};
        $value = '' unless defined $value;

        $params->{$name}->[$index] =
          ref $value eq 'ARRAY' ? $value->[0] : $value;
    }

  FIELD: foreach my $name (keys %{$self->{fields}}) {
        if ($self->{fields}->{$name}->{multiple}) {
            $params->{$name} = [$params->{$name}]
              unless ref $params->{$name} eq 'ARRAY';
        }
        else {
            $params->{$name} = $params->{$name}->[0]
              if ref $params->{$name} eq 'ARRAY';
        }

        foreach my $param (
            ref $params->{$name} eq 'ARRAY'
            ? @{$params->{$name}}
            : $params->{$name}
          )
        {
            for ($param) {
                next FIELD unless defined;

                s/^\s*//g;
                s/\s*$//g;
            }
        }
    }

    return $params;
}

sub _build_rule {
    my $self = shift;
    my ($rule_name, @args) = @_;

    my $rule_class =
      Turnaround::Loader->new(namespaces => $self->{namespaces})
      ->load_class(ucfirst $rule_name);

    return $rule_class->new(@args);
}

1;
