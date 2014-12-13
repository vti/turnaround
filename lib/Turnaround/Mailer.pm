package Turnaround::Mailer;

use strict;
use warnings;

use Encode ();
use Email::MIME;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{subject_prefix} = $params{subject_prefix};
    $self->{signature}      = $params{signature};
    $self->{charset}        = $params{charset} || 'UTF-8';
    $self->{encoding}       = $params{encoding} || 'base64';

    $self->{headers} = $params{headers} || [];

    $self->{transport} = $params{transport};
    die 'transport required' unless $self->{transport};

    return $self;
}

sub send {
    my $self = shift;
    my (%params) = @_;

    my $message = $self->build_message(%params);

    my $transport = $self->{transport};
    if ($transport->{name} eq 'test') {
        open my $mail, '>>', $transport->{path} or die "Can't open test file";
        print $mail $message;
        close $mail;
    }
    elsif ($transport->{name} eq 'sendmail') {
        my $path = "| $transport->{path} -t -oi -oem";

        open my $mail, '>', $path or die "Can't start sendmail: $!";
        print $mail $message;
        close $mail;
    }
    elsif ($transport->{name} eq 'smtp+tls') {
        require Email::Sender::Simple;
        require Email::Sender::Transport::SMTP::TLS;

        my $sender = Email::Sender::Transport::SMTP::TLS->new(
            host     => $transport->{host},
            port     => $transport->{port},
            username => $transport->{username},
            password => $transport->{password}
        );

        Email::Sender::Simple->send($message, {transport => $sender});
    }
    else {
        die 'Unknown transport';
    }
}

sub build_message {
    my $self = shift;
    my (%params) = @_;

    if (defined(my $signature = $self->{signature}) && $params{body}) {
        $params{body} .= "\n\n-- \n$signature";
    }

    my $parts =
      $params{body}
      ? [
        Email::MIME->create(
            attributes => {
                content_type => "text/plain",
                charset      => $self->{charset},
                encoding     => $self->{encoding}
            },
            body_str => $params{body}
        )
      ]
      : ($params{parts} || []);

    my $message = Email::MIME->create(parts => $parts);

    my @headers = (@{$self->{headers}}, @{$params{headers} || []});

    while (my ($key, $value) = splice(@headers, 0, 2)) {
        if ($key eq 'Subject' && (my $prefix = $self->{subject_prefix})) {
            $value = $prefix . ' ' . $value;
        }

        $message->header_str_set($key => $value);
    }

    $message->charset_set($self->{charset});

    return $message->as_string;
}

1;
