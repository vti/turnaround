package MailerTest;

use strict;
use warnings;
use utf8;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use MIME::Base64;
use Turnaround::Mailer;

sub build_message : Test {
    my $self = shift;

    my $mailer = $self->_build_mailer;

    my $message = $mailer->send(
        to      => 'Петр 1 <foo@bar.com>',
        subject => 'Привет',
        body    => 'Привет!'
    );

    like($message, qr/From: .* To:/xms);
}

sub build_message_with_signature : Test {
    my $self = shift;

    my $mailer = $self->_build_mailer(signature => 'hello!');

    my $message = $mailer->send(
        to      => 'Петр 1 <foo@bar.com>',
        subject => 'Привет',
        body    => 'Привет!'
    );

    my ($body) = $message =~ m/\n\n(.*)/;

    $body = MIME::Base64::decode_base64($body);

    like($body, qr/-- \nhello!/);
}

sub _build_mailer {
    my $self = shift;

    return Turnaround::Mailer->new(test => 1, from => 'root <root@localhost>',
        @_);
}

1;
