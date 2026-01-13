# lib/ICTTicketingApp/User.pm
package ICTTicketingApp::User;

sub new {
    my ($class, %args) = @_;
    my $self = {
        id       => $args{id},
        username => $args{username},
    };
    return bless $self, $class;
}

sub id { shift->{id} }
sub username { shift->{username} }

1;