package Lamework::HTTPExceptionResolver::Template;

use strict;
use warnings;

use base 'Lamework::Base';

use Scalar::Util 'blessed';
use HTTP::Status ();

sub BUILD {
    my $self = shift;

    die 'displayer is required' unless $self->{displayer};

    $self->{'404_template'} ||= 'not_found';
    $self->{'403_template'} ||= 'forbidden';
}

sub resolve {
    my $self = shift;
    my ($e, $env) = @_;

    my ($code, $message);

    if (blessed $e && $e->can('code')) {
        $code = $e->code;

        if ($code =~ m/^40(3|4)$/) {
            my $file =
                $code == 404
              ? $self->{'404_template'}
              : $self->{'403_template'};
            $message = $self->{displayer}->render_file($file);
        }
    }
    else {
        $code = 500;
        $env->{'psgi.errors'}->print($e);
    }

    $message ||= HTTP::Status::status_message($code);

    my @headers = (
        'Content-Type'   => 'text/html',
        'Content-Length' => length($message),
    );

    return [$code, \@headers, [$message]];
}

1;
