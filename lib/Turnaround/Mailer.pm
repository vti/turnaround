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

    $self->{headers} = $params{headers} || [];

    return $self;
}

sub send {
    my $self = shift;
    my (%params) = @_;

    my $message = $self->build_message(%params);

    my $transport = $self->{transport};
    if ($transport->{name} eq 'sendmail') {
        if ($self->{test}) {
            open my $mail, '>>', $self->{test} or die "Can't open test file";
            print $mail $message;
            close $mail;
        }
        else {
            my $path = "| $transport->{path} -t -oi -oem";

            open my $mail, '>', $path or die "Can't start sendmail";
            print $mail $message;
            close $mail;
        }
    }
    else {
        die 'Unknown transport';
    }
}

sub build_message {
    my $self = shift;
    my (%params) = @_;

    my $utf8_detected;

    my $parts = $params{body} ? [$params{body}] : ($params{parts} || []);

    foreach my $part (@$parts) {
        if (Encode::is_utf8($part)) {
            $part = Encode::encode('UTF-8', $part);
            $utf8_detected++;
        }
    }

    if (defined(my $signature = $self->{signature})) {
        $parts->[-1] .= "\n\n-- \n$signature";
    }

    my $message = Email::MIME->create(parts => $parts);

    my @headers = (@{$self->{headers}}, @{$params{headers} || []});

    while (my ($key, $value) = splice(@headers, 0, 2)) {
        if (Encode::is_utf8($value)) {
            $utf8_detected++;
        }

        if ($key eq 'Subject' && (my $prefix = $self->{subject_prefix})) {
            $value = $prefix . ' ' . $value;
        }

        $value = Encode::encode('MIME-Header', $value);
        $message->header_str_set($key => $value);
    }

    if ($utf8_detected) {
        $message->charset_set('UTF-8');
        $message->encoding_set('base64');
    }

    return $message->as_string;
}

1;
