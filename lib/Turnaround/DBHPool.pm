package Turnaround::DBHPool;

use strict;
use warnings;

use base 'Turnaround::Base';

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

    my $connection = $self->{connections}->{$pid_tid}
      ||= Turnaround::DBHPool::Connection->new(
        check_timeout => $self->{check_timeout},
        dsn           => $self->{dsn},
        username      => $self->{username},
        password      => $self->{password},
        params        => $self->{params}
      );

    return $connection->dbh;
}

package Turnaround::DBHPool::Connection;

use strict;
use warnings;

use base 'Turnaround::Base';

use DBI;
use Turnaround::Exception::DBHPool;

sub BUILD {
    my $self = shift;

    $self->{check_timeout} = 5 unless defined $self->{check_timeout};
}

sub dbh {
    my $self = shift;

    if (!$self->{dbh}) {
        $self->_connect;
    }
    elsif (!$self->_check_connection) {
        $self->_reconnect;
    }

    return $self->{dbh};
}

sub _connect {
    my $self = shift;

    $self->{dbh}        = $self->_get_dbh;
    $self->{last_check} = time;

    return $self->{dbh};
}

sub _reconnect {
    my $self = shift;

    eval { $self->{dbh}->disconnect };

    return $self->_connect;
}

sub _check_connection {
    my $self = shift;

    return 1 unless $self->_is_check_needed;

    $self->{last_check} = time;

    my $dbh = $self->{dbh};

    return unless $dbh && $dbh->{Active};

    return 1 if int $dbh->ping;

    return eval { $dbh->do('select 1'); 1; };
}

sub _is_check_needed {
    my $self = shift;

    return 1 if !$self->{dbh}->{Active} || $self->_is_check_timeout_elapsed;

    return 0;
}

sub _is_check_timeout_elapsed {
    my $self = shift;

    if ($self->{check_timeout}
        && time - $self->{last_check} > $self->{check_timeout})
    {
        return 1;
    }

    return 0;
}

sub _get_dbh {
    my $self = shift;

    my $dbh = DBI->connect(
        $self->{dsn},      $self->{username},
        $self->{password}, $self->{params}
    );

    Turnaround::Exception::DBHPool->throw("Can't connect $DBI::errstr")
      unless $dbh;

    return $dbh;
}

1;
