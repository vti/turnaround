package Lamework::Middleware::HTTPExceptions;

use strict;
use warnings;

use base 'Plack::Middleware::HTTPExceptions';

use Carp ();
use Try::Tiny;
use Scalar::Util 'blessed';
use HTTP::Status ();

sub new {
    my $self = shift->SUPER::new(@_);

    $self->{'404_template'} ||= 'not_found';
    $self->{'403_template'} ||= 'forbidden';

    return $self;
}

sub transform_error {
    my($self, $e, $env) = @_;

    my($code, $message);
    if (blessed $e && $e->can('code')) {
        $code = $e->code;
        $message =
            $e->can('as_string')       ? $e->as_string :
            overload::Method($e, '""') ? "$e"          : undef;
    } else {
        $code = 500;
        $env->{'psgi.errors'}->print($e);
    }

    if ($code !~ /^[3-5]\d\d$/) {
        die $e; # rethrow
    }

    if ((my $displayer = $env->{'lamework.displayer'})
        && $code =~ m/^40(3|4)$/)
    {
        my $file =
          $code == 404 ? $self->{'404_template'} : $self->{'403_template'};
        $message = $displayer->render_file($file);
    }

    $message ||= HTTP::Status::status_message($code);

    my @headers = (
         'Content-Type'   => 'text/html',
         'Content-Length' => length($message),
    );

    if ($code =~ /^3/ && (my $loc = eval { $e->location })) {
        push(@headers, Location => $loc);
    }

    return [ $code, \@headers, [ $message ] ];
}

1;
