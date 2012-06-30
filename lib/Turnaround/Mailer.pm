package Turnaround::Mailer;

use strict;
use warnings;

use base 'Turnaround::Base';

use Encode ();
use MIME::Lite;

sub BUILD {
    my $self = shift;

    die 'from is required' unless $self->{from};

    $self->{x_mailer} ||= __PACKAGE__;
}

sub send {
    my $self = shift;
    my (%params) = @_;

    $params{to}      ||= $self->{to};
    $params{subject} ||= $self->{subject};
    $params{body}    ||= $self->{body};

    die 'to required'      unless $params{to};
    die 'subject required' unless $params{subject};
    die 'body required'    unless $params{body};

    my $body = $params{body};
    if (my $signature = $self->{signature}) {
        $body .= "\n\n-- \n" . $signature;
    }

    my $message = MIME::Lite->new(
        From     => $self->{from},
        To       => Encode::encode('MIME-Header', $params{to}),
        Subject  => Encode::encode('MIME-Header', $params{subject}),
        Data     => Encode::encode('UTF-8', $body),
        Encoding => 'base64'
    );

    $message->attr('content-type' => 'text/plain; charset=utf-8');

    $message->delete('X-Mailer');
    $message->add('X-Mailer' => $self->{x_mailer});

    $message->send unless $self->{test};

    return $message->as_string;
}

1;
