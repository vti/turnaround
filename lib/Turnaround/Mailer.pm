package Turnaround::Mailer;

use strict;
use warnings;

use Encode ();
use MIME::Lite;

our %TLSConn;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{from}           = $params{from} || die 'from is required';
    $self->{to}             = $params{to};
    $self->{x_mailer}       = $params{x_mailer};
    $self->{send_by}        = $params{send_by};
    $self->{send_args}      = $params{send_args};
    $self->{subject}        = $params{subject};
    $self->{subject_prefix} = $params{subject_prefix};
    $self->{body}           = $params{body};
    $self->{signature}      = $params{signature};
    $self->{test}           = $params{test};

    $self->{headers} = $params{headers} || [];

    $self->{x_mailer} ||= __PACKAGE__;
    $self->{send_by}  ||= 'sendmail';

    return $self;
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

    if (my $prefix = $self->{subject_prefix}) {
        $params{subject} = $prefix . ' ' . $params{subject};
    }

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

    foreach my $header (@{$self->{headers}}) {
        my ($key, $value) = split /\s*:\s*/, $header;
        $message->add($key => $value);
    }

    if ($self->{test}) {
        if ($self->{test} ne 1) {
            open my $log, '>>', $self->{test}
              or die "Can't open log '$self->{test}': $!";
            print $log $message->as_string;
        }
    }
    else {
        my $method = "send_by_$self->{send_by}";
        $message->$method(@{$self->{send_args}});
    }

    return $message->as_string;
}

# http://svn.bulknews.net/repos/plagger/trunk/plagger/lib/Plagger/Plugin/Publish/Gmail.pm
# hack MIME::Lite to support TLS Authentication
*MIME::Lite::send_by_smtp_tls = sub {
    my ($self, @args) = @_;
    my $extract_addrs_ref =
      defined &MIME::Lite::extract_addrs
      ? \&MIME::Lite::extract_addrs
      : \&MIME::Lite::extract_full_addrs;

    ### We need the "From:" and "To:" headers to pass to the SMTP mailer:
    my $hdr    = $self->fields();
    my ($from) = $extract_addrs_ref->($self->get('From'));
    my $to     = $self->get('To');

    ### Sanity check:
    defined($to) or Carp::croak "send_by_smtp_tls: missing 'To:' address\n";

    ### Get the destinations as a simple array of addresses:
    my @to_all = $extract_addrs_ref->($to);
    if ($MIME::Lite::AUTO_CC) {
        foreach my $field (qw(Cc Bcc)) {
            my $value = $self->get($field);
            push @to_all, $extract_addrs_ref->($value) if defined($value);
        }
    }

    ### Create SMTP TLS client:
    require Net::SMTP::TLS;

    my $conn_key = join "|", @args;
    my $smtp;
    unless ($smtp = $TLSConn{$conn_key}) {
        $smtp = $TLSConn{$conn_key} = MIME::Lite::SMTP::TLS->new(@args)
          or Carp::croak("Failed to connect to mail server: $!\n");
    }
    $smtp->mail($from);
    $smtp->to(@to_all);
    $smtp->data();

    ### MIME::Lite can print() to anything with a print() method:
    $self->print_for_smtp($smtp);
    $smtp->dataend();

    1;
};

@MIME::Lite::SMTP::TLS::ISA = qw( Net::SMTP::TLS );
sub MIME::Lite::SMTP::TLS::print { shift->datasend(@_) }

1;
