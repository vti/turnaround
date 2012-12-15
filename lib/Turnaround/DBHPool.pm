package Turnaround::DBHPool;

use strict;
use warnings;

use Turnaround::DBHPool::Connection;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{check_timeout} = $params{check_timeout};
    $self->{dsn}           = $params{dsn};
    $self->{username}      = $params{username};
    $self->{password}      = $params{password};
    $self->{params}        = $params{params};

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
