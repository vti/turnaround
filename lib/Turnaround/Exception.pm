package Turnaround::Exception;

use strict;
use warnings;

use base 'Exporter';
our @EXPORT = (qw(raise));

require Scalar::Util;

use Turnaround::Loader;
use Turnaround::Exception::Base;

my $OLD_DIE = $SIG{__DIE__};
$SIG{__DIE__} = sub { _die([caller], @_) };

sub raise(@) {
    my ($exception_class, @args) = @_;

    $exception_class ||= __PACKAGE__ . '::Base';

    if (!_try_load_class($exception_class)) {
        _create_class($exception_class);
    }

    unshift @args, 'message' if @args == 1;
    $exception_class->throw(caller => [caller(0)], @args);
}

sub _try_load_class { Turnaround::Loader->new->try_load_class(@_) }

sub _die {
    my ($caller, $e) = @_;

    local $SIG{__DIE__} = $OLD_DIE;

    return unless $^S;

    if (!Scalar::Util::blessed($e)) {
        $e =~ s/ at .*? line .*?\.//;
        chomp $e;
        $e = Turnaround::Exception::Base->new(message => $e, caller => $caller);
    }

    CORE::die($e);
}

sub _create_class {
    my ($class) = @_;

    eval <<"EOF";
package $class;
use base 'Turnaround::Exception::Base';
EOF

    return $class;
}

1;
