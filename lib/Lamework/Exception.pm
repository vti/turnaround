package Lamework::Exception;

use strict;
use warnings;

use base 'Exporter';
our @EXPORT = (qw(try catch finally raise die));

require Try::Tiny;
require Scalar::Util;

use Lamework::Loader;
use Lamework::Exception::Base;

sub die (@);

$SIG{__DIE__} = sub { _die([caller], @_) };

sub import {
    my $pkg = shift;

    $pkg->export('CORE::GLOBAL', 'die');

    $pkg->export_to_level(1, $pkg, @EXPORT);
}

sub die (@) { _die([caller], @_) }

sub try(&;@)     { goto &Try::Tiny::try }
sub catch(&;@)   { goto &Try::Tiny::catch }
sub finally(&;@) { goto &Try::Tiny::finally }

sub raise(@) {
    my ($exception_class, @args) = @_;

    $exception_class ||= __PACKAGE__ . '::Base';

    if (!Lamework::Loader->is_class_loaded($exception_class)) {
        my $path = $exception_class;
        $path =~ s{::}{/}g;
        $path .= '.pm';
        eval { require $path; 1 } or do {
            delete $INC{$path};
            my $e = $@;
            CORE::die $e unless $e =~ m{^Can't locate \Q$path\E in \@INC };
            _create_class($exception_class);
        };
    }

    unshift @args, 'message' if @args == 1;
    $exception_class->throw(caller => [caller(0)], @args);
}

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
