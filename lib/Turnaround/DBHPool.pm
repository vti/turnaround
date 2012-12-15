package Turnaround::DBHPool;

use strict;
use warnings;

use base 'Turnaround::Base';

use Turnaround::DBHPool::Connection;

sub BUILD {
    my $self = shift;

    $self->{connections} = {};

    return $self;
}

sub dbh {
    my $self = shift;

    # From DBIx::Connector
    my $pid_tid = $$;
    $pid_tid .= '_' . threads->tid
      if exists $INC{'threads.pm'} && $INC{'threads.pm'};

    my $connection = $self->{connections}->{$pid_tid} ||=
      Turnaround::DBHPool::Connection->new(
        check_timeout => $self->{check_timeout},
        dsn           => $self->{dsn},
        username      => $self->{username},
        password      => $self->{password},
        params        => $self->{params}
      );

    return $connection->dbh;
}

1;
