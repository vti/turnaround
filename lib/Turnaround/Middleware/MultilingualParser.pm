package Turnaround::Middleware::MultilingualParser;

use strict;
use warnings;

use base 'Turnaround::Middleware';

sub new {
    my $self = shift->SUPER::new(@_);

    die 'default_language is required' unless $self->{default_language};
    die 'languages are required'       unless $self->{languages};

    return $self;
}

sub call {
    my $self = shift;
    my ($env) = @_;

    my $res = $self->app->(@_);

    return $self->response_cb(
        $res => sub {
            my $res = shift;
            my $h   = Plack::Util::headers($res->[1]);

            return unless my $content_type = $h->get('Content-Type');
            return unless $content_type =~ m{text/html};

            my $language = $env->{'lamework.language'};
            return unless $language;

            my $pattern =
              "<t>\\s*.*?<$language>\\s*(.*?)\\s*</$language>\\s*.*?</t>";

            my $body = '';
            Plack::Util::foreach(
                $res->[2],
                sub {
                    while ($_[0] =~ s/$pattern/$1/) { }
                    $body .= $_[0];
                }
            );

            # TODO chunks

            $res->[2] = [$body];

            $h->set('Content-Length', length $body);
        }
    );
}

1;
