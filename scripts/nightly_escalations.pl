#!/usr/bin/perl
# scripts/nightly_escalation.pl

use strict;
use warnings;
use DBI;
use YAML::XS;
use Email::Stuffer;
use DateTime;

# Load configuration
my $config = YAML::XS::LoadFile('../config.yml');

# Database connection
my $dsn = "DBI:mysql:database=$config->{db_name};host=$config->{db_host}";
my $dbh = DBI->connect($dsn, $config->{db_user}, $config->{db_pass}, { RaiseError => 1 });

# Find pending tickets older than 7 days
my $sth = $dbh->prepare(
    "SELECT ticket_number, created_at FROM tickets WHERE status = 'PENDING' AND updated_at < NOW() - INTERVAL 7 DAY"
);
$sth->execute;

my @pending_tickets;
while (my $row = $sth->fetchrow_hashref) {
    push @pending_tickets, $row;
}

if (@pending_tickets) {
    my $body = "The following tickets have been pending for more than 7 days:\n\n";
    foreach my $ticket (@pending_tickets) {
        $body .= "Ticket Number: " . $ticket->{ticket_number} . "\n";
    }

    Email::Stuffer->from('noreply@tkthelpdesk.com')
                  ->to($config->{escalation_email})
                  ->subject('Escalation: Pending Tickets')
                  ->text_body($body)
                  ->send_or_die;
}

$dbh->disconnect;

exit;
