
package Jukebox;

# Jukebox and media definitions, dependant upon the master shell
# configuration file, 'juke.config'.  This ensures that declarations
# appear in only one file.  All configuration changes should be made
# to the shell file, and we'll inherit them here.

use Exporter;
use base qw/Exporter/;
@EXPORT = qw/
    $CHANGER $EEPOS_OPEN $EEPOS_SHUT $JUKE
    $LOADERINFO $MT $MTX $NRTAPE sys $TAPE
    $VERSION
/;

our (
     $CHANGER,
     $EEPOS_OPEN,
     $EEPOS_SHUT,
     $JUKE,
     $LOADERINFO,
     $MT,
     $MTX,
     $NRTAPE,
     $TAPE,
     $VERSION,
);

my $sconfig = 'JUKE_ROOT/juke.config';
if ( ! open S, $sconfig ) {
    $sconfig = 'juke.config';
    open S, $sconfig or die "Cannot open '$sconfig' for read: $!";
}
my (@setup) = <S>;
close S;


my $setup = join ' ', @setup;

($CHANGER)    = $setup =~ / CHANGER=(.*)/m;
($EEPOS_OPEN) = $setup =~ / EEPOS_OPEN=(.*)/m;
($EEPOS_SHUT) = $setup =~ / EEPOS_SHUT=(.*)/m;
($JUKE)       = $setup =~ / JUKE=(.*)/m;
($LOADERINFO) = $setup =~ / LOADERINFO=(.*)/m;
($MT)         = $setup =~ / MT=(.*)/m;
($MTX)        = $setup =~ / MTX=(.*)/m;
($NRTAPE)     = $setup =~ / NRTAPE=(.*)/m;
($TAPE)       = $setup =~ / TAPE=(.*)/m;
($VERSION)    = $setup =~ / VERSION=(.*)/m;

sub sys {

    # Execute a command.  If problems, die/warn as appropriate.

    my ($cmd, $warn) = @_;
    my (@out) = `$cmd`;
    return @out unless $?;
    my $err = "Failed : '$cmd' : " . ($? >> 8);
    $warn ? warn $err : die $err;
    return @out;

} # end sys

1;
