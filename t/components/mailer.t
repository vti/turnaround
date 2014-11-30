use strict;
use warnings;
use utf8;

use Test::More;
use Test::Fatal;

use File::Temp;
use MIME::Base64;
use Turnaround::Mailer;

subtest 'build_message' => sub {
    my $mailer = _build_mailer();

    my $message = $mailer->build_message(
        headers => [
            To      => 'Foo <foo@bar.com>',
            Subject => 'Bar'
        ],
        parts => ['Baz!']
    );

    like($message, qr{From: root <root\@localhost>});
    like($message, qr{Date: });
    like($message, qr{MIME-Version: 1\.0});
    like($message, qr{Content-Transfer-Encoding: 7bit});
    like($message, qr{Content-Type: text/plain; charset="UTF-8"});
    like($message, qr{To: Foo <foo\@bar.com>});
    like($message, qr{Subject: Bar});
    like($message, qr{Baz!});
};

subtest 'build_message_with_simple_body' => sub {
    my $mailer = _build_mailer();

    my $message = $mailer->build_message(body => 'Hi');

    like($message, qr{SGk=});
};

subtest 'build_message_with_unicode' => sub {
    my $mailer = _build_mailer();

    my $message = $mailer->build_message(
        headers => [
            To      => 'Петр 1 <foo@bar.com>',
            Subject => 'Привет'
        ],
        body => 'Привет!'
    );

    like($message, qr{\QTo: =?UTF-8?B?0J/QtdGC0YAgMQ==?=\E <foo\@bar.com>});
    like($message, qr{\QSubject: =?UTF-8?B?0J/RgNC40LLQtdGC?=\E});
    like($message, qr{\Q0J/RgNC40LLQtdGCIQ==\E});
};

subtest 'build_message_with_custom_headers' => sub {
    my $mailer = _build_mailer(headers => ['Foo' => 'http://foo.com']);

    my $message = $mailer->build_message();

    like($message, qr{Foo:[ ]http://foo.com}xms);
};

subtest 'build_message_with_defaults' => sub {
    my $mailer =
      _build_mailer(headers => [To => 'foo@bar.com', Subject => 'Hello!']);

    my $message = $mailer->build_message();

    like($message, qr/To:\s*foo\@bar\.com/xms);
    like($message, qr/Subject:\s*Hello!/xms);
};

subtest 'build_message_with_overriden_headers' => sub {
    my $mailer = _build_mailer(headers => [To => 'foo@bar.com'],);

    my $message = $mailer->build_message(headers => [To => 'bar@foo.com']);

    like($message, qr{bar\@foo.com});
    unlike($message, qr{foo\@bar.com});
};

subtest 'build_message_with_subject_prefix' => sub {
    my $mailer = _build_mailer(subject_prefix => '[Turnaround]');

    my $message = $mailer->build_message(headers => [Subject => 'Hello!']);

    like($message, qr/Subject:\s*\[Turnaround\]\s*Hello!/xms);
};

subtest 'build_message_with_signature' => sub {
    my $mailer = _build_mailer(signature => 'hello!');

    my $message = $mailer->build_message(body => 'Hi!');

    like($message, qr/SGkhCgotLSAKaGVsbG8h/);
};

subtest 'build_message_with_unicode_signature' => sub {
    my $mailer = _build_mailer(signature => 'Привет!');

    my $message = $mailer->build_message(body => 'Да!');

    like($message, qr/0JTQsCEKCi0tIArQn9GA0LjQstC10YIh/);
};

subtest 'send_mail' => sub {
    my $file = File::Temp->new;

    my $mailer =
      _build_mailer(transport => {name => 'test', path => $file->filename});

    $mailer->send(headers => [From => 'me', To => 'you'], body => 'Hi!');

    my $message = do { local $/; open my $fh, '<', $file; <$fh> };
    like($message, qr{me});
    like($message, qr{you});
    like($message, qr{SGkh});
};

sub _build_mailer {
    return Turnaround::Mailer->new(
        test      => 1,
        headers   => [From => 'root <root@localhost>'],
        transport => {name => 'test'},
        @_
    );
}

done_testing;
