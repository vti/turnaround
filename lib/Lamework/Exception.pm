package Lamework::Exception;

use strict;
use warnings;

use base 'Exporter';
our @EXPORT = (qw(try catch finally raise));

require Try::Tiny;
require Scalar::Util;

use Lamework::Loader;
use Lamework::Exception::Base;

$SIG{__DIE__} = sub { _die([caller], @_) };

sub try(&;@)     { goto &Try::Tiny::try }
sub catch(&;@)   { goto &Try::Tiny::catch }
sub finally(&;@) { goto &Try::Tiny::finally }

sub raise(@) {
    my ($exception_class, @args) = @_;

    $exception_class ||= __PACKAGE__ . '::Base';

    if (!_try_load_class($exception_class)) {
        _create_class($exception_class);
    }

    unshift @args, 'message' if @args == 1;
    $exception_class->throw(caller => [caller(0)], @args);
}

sub _try_load_class { Lamework::Loader->new->try_load_class(@_) }

sub _die {
    my ($caller, $e) = @_;

    return unless $^S;

    if (!Scalar::Util::blessed($e)) {
        $e = Lamework::Exception::Base->new(message => $e, caller => $caller);
    }

    CORE::die $e;
}

sub _create_class {
    my ($class) = @_;

    eval <<"EOF";
package $class;
use base 'Lamework::Exception::Base';
EOF

    return $class;
}

1;
