use Irssi;
use vars qw/ $VERSION %IRSSI /;
use Data::Dumper;

$VERSION = 0.10;
%IRSSI = (
    authors     => 'SymKat',
    contact     => 'symkat@symkat.com',
    name        => 'chanoply',
    decsription => 'Minimalist ChanOp Serv',
    license     => 'BSD',
    url         => 'http://github.com/symkat/chanoply',
    changed     => '2011-01-30',
    changes     => 'See Change Log',
);

# Bindings
Irssi::signal_add( 'message public', \&input );

# Commands
Irssi::command_bind( 'chanoply', \&list_control );

# Settings
Irssi::settings_add_str( 'chanoply', $IRSSI{name} . '_path', '.irssi/chanoply' );
Irssi::settings_add_str( 'chanoply', $IRSSI{name} . '_cmd', '.opme' );

my $auth = load();

# Short Cuts 
sub tell_user { Irssi::active_win()->print( shift ); }
sub file_path { Irssi::settings_get_str( $IRSSI{name} . '_path' ); }
sub cmd       { Irssi::settings_get_str( $IRSSI{name} . '_cmd'  ); }

sub input {
    my ( $server, $msg, $nick, $address, $target ) = @_;
    return unless $msg eq cmd;
    if ( exists $auth->{$server->{address}}->{$target}->{$address} ) {
        $server->command( "MODE $target +o $nick" );
    }
}

sub list_control {
    my ( $input, $server, $witem ) = @_;  
    # Debug Dumping
    if ( $input =~ /magic/ ) {
        tell_user Dumper $auth;
    }
    
    my ( $action, $nick ) = ( split( /\s+/, $input, 2) );

    # Strip Spaces.
    s/^\s+//, s/\s+$// for $action, $nick; 

    # Error checking is fun.
    if ( $action ne 'add' and $action ne 'del'  ) {
        tell_user "Invalid action.";
        return;
    }

    if ( not $server or not $server->{connected} ) {
        tell_user "Not connected to server.";
        return;
    }

    if ( $witem->{type} ne 'CHANNEL' ) {
        tell_user "Not in a channel.";
        return;
    }
    
    # Grab the host for the user.
    my ( $host ) = map { $_->{host} } 
        grep { $_->{nick} eq $nick } $witem->nicks;

    # Do we have a valid hostname now?
    if ( not $host ) {
        tell_user "That nickname doesn't seem to be here.";
        return;
    }

    # Run the command.
    
    if ( $action eq 'add' ) {
        add_entry( $server->{address}, $witem->{name}, $host );
    } elsif ( $action eq 'del' ) {
        del_entry( $server->{address}, $witem->{name}, $host );
    }
    
    return;
}

sub add_entry {
    my ( $server, $channel, $host ) = @_;
    $auth->{$server}->{$channel}->{$host} = 1;
    sync();
}

sub del_entry {
    my ( $server, $channel, $host ) = @_;
    delete $auth->{$server}->{$channel}->{$host};
    sync();
}

sub load {
    open my $lf, "<", file_path or do {
        tell_user "Failed to read $file: $!";
        return;
    };

    my $auth;
    while ( my $line = <$lf>  ) {
        chomp $line;
        my ( $server, $channel, $host ) = ( split /:/, $line, 3 );
        $auth->{$server}->{$channel}->{$host} = 1;
    }
    close $lf;
    return $auth;
}

sub sync {
    my $contents;

    for my $server ( keys %{$auth} ) {
        for my $channel ( keys %{$auth->{$server}} ) {
            for my $host ( keys %{$auth->{$server}->{$channel}}  ) {
                $contents .= "$server:$channel:$host\n";
            }
        }
    }
    
    open my $sf, ">", file_path or do {
        tell_user "Failed to write $file for sync: $!";
        return;
    };
    
    print $sf $contents;
    close $sf;
    return;
}
