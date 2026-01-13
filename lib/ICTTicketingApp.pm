# lib/ICTTicketingApp.pm
package ICTTicketingApp;
use Dancer2;
use ICTTicketingApp::Authentication;
use ICTTicketingApp::Ticket;
use ICTTicketingApp::User;

our $VERSION = '0.1';

# Route for user authentication
post '/login' => sub {
    my $user = ICTTicketingApp::Authentication->login(
        params->{userid},
        params->{password}
    );

    if ($user) {
        my $encrypted_user_data = ICTTicketingApp::Authentication->encrypt_user_data($user);
        return { status => 'success', user_data => $encrypted_user_data };
    } else {
        status 401;
        return { status => 'error', message => 'Invalid credentials' };
    }
};

# Route to create a new ticket
post '/ticket/create' => sub {
    my $user = ICTTicketingApp::Authentication->get_user_from_request(request);
    unless ($user) {
        status 401;
        return { status => 'error', message => 'Unauthorized' };
    }

    my $ticket_number = ICTTicketingApp::Ticket->create(
        params->{description},
        $user->id
    );

    if ($ticket_number) {
        return { status => 'success', ticket_number => $ticket_number };
    } else {
        status 500;
        return { status => 'error', message => 'Failed to create ticket' };
    }
};

# Route to update a ticket
put '/ticket/update/:ticket_number' => sub {
    my $user = ICTTicketingApp::Authentication->get_user_from_request(request);
    unless ($user) {
        status 401;
        return { status => 'error', message => 'Unauthorized' };
    }

    my $updated = ICTTicketingApp::Ticket->update(
        params->{ticket_number},
        params->{status}
    );

    if ($updated) {
        return { status => 'success' };
    } else {
        status 404;
        return { status => 'error', message => 'Ticket not found or update failed' };
    }
};

# Route to view a ticket
get '/ticket/view/:ticket_number' => sub {
    my $user = ICTTicketingApp::Authentication->get_user_from_request(request);
    unless ($user) {
        status 401;
        return { status => 'error', message => 'Unauthorized' };
    }

    my $ticket = ICTTicketingApp::Ticket->view(params->{ticket_number});

    if ($ticket) {
        return { status => 'success', ticket => $ticket };
    } else {
        status 404;
        return { status => 'error', message => 'Ticket not found' };
    }
};

true;