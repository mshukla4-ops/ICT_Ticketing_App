# lib/ICTTicketingApp/Ticket.pm
package ICTTicketingApp::Ticket;

use Dancer2;
use DBI;
use String::Random;

sub _db_handle {
    my $config = config;
    my $dsn = "DBI:mysql:database=$config->{db_name};host=$config->{db_host}";
    return DBI->connect($dsn, $config->{db_user}, $config->{db_pass}, { RaiseError => 1 });
}

sub create {
    my ($class, $description, $user_id) = @_;
    my $dbh = $class->_db_handle;
    my $ticket_number = 'TKT-' . String::Random->new->randregex('[A-Z0-9]{8}');
    
    my $sth = $dbh->prepare(
        "INSERT INTO tickets (ticket_number, description, status, user_id, created_at, updated_at) VALUES (?, ?, 'NEW', ?, NOW(), NOW())"
    );
    my $rv = $sth->execute($ticket_number, $description, $user_id);

    return $rv ? $ticket_number : undef;
}

sub update {
    my ($class, $ticket_number, $status) = @_;
    return unless $status =~ /^(PENDING|CLOSED)$/;

    my $dbh = $class->_db_handle;
    my $sth = $dbh->prepare(
        "UPDATE tickets SET status = ?, updated_at = NOW() WHERE ticket_number = ?"
    );
    my $rv = $sth->execute($status, $ticket_number);
    return $rv;
}

sub view {
    my ($class, $ticket_number) = @_;
    my $dbh = $class->_db_handle;
    my $sth = $dbh->prepare(
        "SELECT description, status FROM tickets WHERE ticket_number = ?"
    );
    $sth->execute($ticket_number);
    return $sth->fetchrow_hashref;
}

1;