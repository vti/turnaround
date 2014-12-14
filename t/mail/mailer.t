use strict;
use warnings;
use utf8;

use Test::More;
use Test::Requires;
use Test::Fatal;

BEGIN { test_requires 'Email::MIME' }

use File::Temp;
use MIME::Base64;
use Turnaround::Mailer;

subtest 'throws when no transport' => sub {
    like exception { _build_mailer(transport => undef) },
      qr/transport required/;
};

subtest 'builds message' => sub {
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

subtest 'builds message without headers' => sub {
    my $mailer = _build_mailer(headers => undef);

    my $message = $mailer->build_message(body => 'Hi');

    like($message, qr{SGk=\s*$});
};

subtest 'builds message with specified encoding' => sub {
    my $mailer = _build_mailer(encoding => '8bit');

    my $message = $mailer->build_message(body => 'Hi');

    like($message, qr{Hi$});
};

subtest 'builds message with specified charset' => sub {
    my $mailer = _build_mailer(charset => 'koi8-r');

    my $body = 'привет';
    Encode::from_to(Encode::encode('UTF-8', $body), 'UTF-8', 'koi8-r');
    my $message = $mailer->build_message(body => $body);

    like($message, qr{0NLJ18XU\s*$});
};

subtest 'builds message with simple body' => sub {
    my $mailer = _build_mailer();

    my $message = $mailer->build_message(body => 'Hi');

    like($message, qr{SGk=\s*$});
};

subtest 'builds message with unicode' => sub {
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

subtest 'builds message with custom headers' => sub {
    my $mailer = _build_mailer(headers => ['Foo' => 'http://foo.com']);

    my $message = $mailer->build_message();

    like($message, qr{Foo:[ ]http://foo.com}xms);
};

subtest 'builds message with defaults' => sub {
    my $mailer =
      _build_mailer(headers => [To => 'foo@bar.com', Subject => 'Hello!']);

    my $message = $mailer->build_message();

    like($message, qr/To:\s*foo\@bar\.com/xms);
    like($message, qr/Subject:\s*Hello!/xms);
};

subtest 'builds message with overriden headers' => sub {
    my $mailer = _build_mailer(headers => [To => 'foo@bar.com'],);

    my $message = $mailer->build_message(headers => [To => 'bar@foo.com']);

    like($message, qr{bar\@foo.com});
    unlike($message, qr{foo\@bar.com});
};

subtest 'builds message with subject prefix' => sub {
    my $mailer = _build_mailer(subject_prefix => '[Turnaround]');

    my $message = $mailer->build_message(headers => [Subject => 'Hello!']);

    like($message, qr/Subject:\s*\[Turnaround\]\s*Hello!/xms);
};

subtest 'does not build message with signature but without body' => sub {
    my $mailer = _build_mailer(signature => 'hello!');

    my $message = $mailer->build_message();

    like $message, qr/\r?\n\r?\n$/;
};

subtest 'builds message with signature' => sub {
    my $mailer = _build_mailer(signature => 'hello!');

    my $message = $mailer->build_message(body => 'Hi!');

    like($message, qr/SGkhCgotLSAKaGVsbG8h/);
};

subtest 'builds message with unicode signature' => sub {
    my $mailer = _build_mailer(signature => 'Привет!');

    my $message = $mailer->build_message(body => 'Да!');

    like($message, qr/0JTQsCEKCi0tIArQn9GA0LjQstC10YIh/);
};

subtest 'send mail' => sub {
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
