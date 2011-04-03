package MyAppI18N::Action::Foo;

use base 'Lamework::Action';

sub run {
    my $self = shift;

    my $language  = $self->env->{'lamework.i18n.language'};
    my $languages = $self->env->{'lamework.i18n.languages'};

    $self->res->code(200);
    $self->res->body(join ',' => $self->url_for('foo'), $language, join '|', @$languages);
}

1;
