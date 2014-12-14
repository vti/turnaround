package Turnaround::Test;

use strict;
use warnings;

use Carp qw(croak);
use Test::MonkeyMock;

use Turnaround::DispatchedRequest;

sub build_env {
    my $class = shift;
    my (%params) = @_;

    my $method = 'GET';
    my $content;
    my $content_type = 'application/x-www-form-urlencoded';

    if (exists $params{upload}) {
        $method       = 'POST';
        $content_type = 'multipart/form-data; boundary=123';

        my $name     = $params{upload}->{name};
        my $filename = $params{upload}->{filename};
        my $file     = $params{upload}->{content};
        my $type     = $params{upload}->{type};

        $content .= join "\x0d\x0a",
          '--123',
qq{Content-Disposition: form-data; name="$name"; filename="$filename"},
          "Content-Type: $type", '',
          $file;
    }

    if (exists $params{form}) {
        if ($content_type =~ m{multipart/form}) {
            my $form = delete $params{form};
            foreach my $key (keys %{$form}) {
                my $value = $form->{$key};

                $content .= "\x0d\x0a" . join "\x0d\x0a",
                  '--123',
                  qq{Content-Disposition: form-data; name="$key"}, '',
                  $value;
            }
        }
        else {
            $content = _build_params(delete $params{form});
        }

        $method = 'POST';
    }

    if ($content_type =~ m{multipart/form}) {
        $content .= "\x0d\x0a--123\x0d\x0a\x0d\x0a";
    }

    my $env = {
        REQUEST_METHOD                  => $method,
        'psgix.session'                 => {},
        'psgix.session.options'         => {},
        'turnaround.dispatched_request' => _build_dispatched_request(%params),
        %params
    };

    if (my $query = delete $params{query}) {
        $env->{QUERY_STRING} = _build_params($query);
    }

    if (defined $content) {
        open my $fh, '<', \$content ## no critic 'InputOutput::RequireBriefOpen'
          or croak $!;

        $env = {
            %$env,
            'psgi.input'   => $fh,
            REQUEST_METHOD => 'POST',
            CONTENT_TYPE   => $content_type,
            CONTENT_LENGTH => length($content),
        };
    }

    return $env;
}

sub _build_dispatched_request {
    my (%params) = @_;

    my $dr = Turnaround::DispatchedRequest->new;
    $dr = Test::MonkeyMock->new($dr);
    $dr->mock(build_path => sub { '' });
    $dr->mock(captures   => sub { $params{captures} });

    return $dr;
}

sub _build_params {
    my $params = shift;

    my @pairs;
    foreach my $key (keys %$params) {
        my $value = $params->{$key};

        if (ref $value eq 'ARRAY') {
            push @pairs, "$key=$_" for @$value;
        }
        else {
            push @pairs, "$key=$value";
        }
    }

    return join '&', @pairs;
}

1;
