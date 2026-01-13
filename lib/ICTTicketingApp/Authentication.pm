# lib/ICTTicketingApp/Authentication.pm
package ICTTicketingApp::Authentication;

use Dancer2;
use DBI;
use Crypt::CBC;
use MIME::Base64;
use ICTTicketingApp::User;

sub _db_handle {
    my $config = config;
    my $dsn = "DBI:mysql:database=$config->{db_name};host=$config->{db_host}";
    return DBI->connect($dsn, $config->{db_user}, $config->{db_pass}, { RaiseError => 1 });
}

sub login {
    my ($class, $userid, $password) = @_;
    my $dbh = $class->_db_handle;
    my $sth = $dbh->prepare("SELECT id, password_hash FROM users WHERE username = ?");
    $sth->execute($userid);

    if (my $row = $sth->fetchrow_hashref) {
        # In a real application, use a proper password hashing module like Authen::Passphrase
        if ($row->{password_hash} eq $password) { # Simplified for example
            return ICTTicketingApp::User->new(id => $row->{id}, username => $userid);
        }
    }
    return;
}

sub encrypt_user_data {
    my ($class, $user) = @_;
    my $cipher = Crypt::CBC->new(
        -key    => config->{encryption_key},
        -cipher => 'Rijndael'
    );
    my $user_data = $user->id . '|' . $user->username;
    my $encrypted = $cipher->encrypt($user_data);
    return encode_base64($encrypted);
}

sub get_user_from_request {
    my ($class, $request) = @_;
    my $encrypted_data = $request->header('X-User-Data');
    return unless $encrypted_data;

    my $cipher = Crypt::CBC->new(
        -key    => config->{encryption_key},
        -cipher => 'Rijndael'
    );
    my $decrypted = $cipher->decrypt(decode_base64($encrypted_data));
    my ($id, $username) = split /\|/, $decrypted;

    if ($id && $username) {
        return ICTTicketingApp::User->new(id => $id, username => $username);
    }
    return;
}

1;