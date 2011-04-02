package MyAppI18N::Action::Foo;

use base 'Lamework::Action';

sub run {
    my $self = shift;

    $self->res->code(200);
    $self->res->body($self->url_for('foo'));
}

1;
