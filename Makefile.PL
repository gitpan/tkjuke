our $VERSION = '1.0.6';

use Tk::MMutil;

use strict;

$| = 1;

our (
     $PERL,
     $PREFIX,

     $JUKE_ROOT,
     $JUKE_EXE,

     $CHANGER,
     $EEPOS_OPEN,
     $EEPOS_SHUT,
     $JUKE,
     $LOADERINFO,
     $MT,
     $MTX,
     $NRTAPE,
     $TAPE,
);

$PERL       = '/usr/local/bin/perl';
$PREFIX     = '/usr/local';

$JUKE_ROOT  = "$PREFIX/tkjuke/$VERSION";
$JUKE_EXE   = "$JUKE_ROOT/juke";

# juke.config variables.

$CHANGER    = '/dev/sch0';
$EEPOS_OPEN = 0;
$EEPOS_SHUT = 1;
$JUKE       = $JUKE_EXE;
$LOADERINFO = '/usr/local/sbin/loaderinfo';
$MT         = '/bin/mt';
$MTX        = '/usr/local/sbin/mtx';
$NRTAPE     = '/dev/nst0';
$TAPE       = '/dev/st0';

sub MY::post_initialize {

    my ($self) = @_;

    # Create juke.config

    &configure;

    return '';

}

sub MY::install {

    <<"END";
install::
\t-mkdir $PREFIX/tkjuke  2> /dev/null
\tcp -Rp blib/$VERSION $PREFIX/tkjuke/
END

}

Tk::MMutil::TkExtMakefile(
    NAME          => "tkjuke",
    DISTNAME      => "tkjuke",
    VERSION_FROM  => "Makefile.PL",
    PM            => undef,
    dist          => {COMPRESS => 'gzip', SUFFIX => 'gz'},
    ABSTRACT      => 'Jukebox interface for mtx',
    AUTHOR        => 'Steve Lidie (sol0@lehigh.edu)',
);

sub configure {

    # Define PERL and PREFIX.

    print "\nFirst, let's collect some general information about this install.\n";

    $PERL = get($PERL, << "END");
Please enter the pathname of Perl
END

    $PREFIX = get($PREFIX, << "END");
Please enter the prefix pathname for tkjuke and it's support
files. If you choose the default value '$PREFIX', then
the directory '$PREFIX/tkjuke/$VERSION' is created
END

    # Define all juke.config variables.

    $JUKE_ROOT   = "$PREFIX/tkjuke/$VERSION";
    $JUKE_EXE    = "$JUKE_ROOT/juke";
    $JUKE        = $JUKE_EXE;

    print "\nNow I need mtx, jukebox and tape device configuration data.\n";

    $CHANGER = get($CHANGER, << "END");
Please enter the device name of the changer
END

    $EEPOS_OPEN = get($EEPOS_OPEN, << "END");
Please enter the hardware code to open the mail slot
END

    $EEPOS_SHUT = get($EEPOS_SHUT, << "END");
Please enter the hardware code to close the mail slot
END

    $LOADERINFO = get($LOADERINFO, << "END");
Please enter the pathname of the 'loaderinfo' command
END

    $MT = get($MT, << "END");
Please enter the pathname of the 'mt' command
END

    $MTX = get($MTX, << "END");
Please enter the pathname of the 'mtx' command
END

    $NRTAPE = get($NRTAPE, << "END");
Please enter the device name of the no rewind tape
END

    $TAPE = get($TAPE, << "END");
Please enter the device name of the rewind tape
END

    print <<"END";

perl       =     $PERL
prefix     =     $PREFIX
changer    =     $CHANGER
eepos_open =     $EEPOS_OPEN
eepos_shut =     $EEPOS_SHUT
juke       =     $JUKE
loaderinfo =     $LOADERINFO
mt         =     $MT
mtx        =     $MTX
nrtape     =     $NRTAPE
tape       =     $TAPE
version    =     $VERSION
END

    print "\nWriting juke.config.\n";
    open J, ">juke.config" or die "Cannot open juke.config: $!";
    print J <<"END";
export CHANGER=$CHANGER
export EEPOS_OPEN=$EEPOS_OPEN
export EEPOS_SHUT=$EEPOS_SHUT
export JUKE=$JUKE
export LOADERINFO=$LOADERINFO
export MT=$MT
export MTX=$MTX
export NRTAPE=$NRTAPE
export TAPE=$TAPE
export VERSION=$VERSION
END
    close J;

    print "\nPerforming string substitutions ...";
    my $blib_root = "./blib/$VERSION";
    system <<"END";
mkdir ./blib  2> /dev/null
mkdir $blib_root      2> /dev/null
mkdir $blib_root/Proc 2> /dev/null
mkdir $blib_root/Tk   2> /dev/null
$PERL -ne "s+JUKE_ROOT+$JUKE_ROOT+g; s+PERL+$PERL+; print"                           juke > $blib_root/juke
$PERL -ne "s+JUKE_ROOT+$JUKE_ROOT+g; s+PERL+$PERL+; s+JUKE_EXE+$JUKE_EXE+g; print" tkjuke > $blib_root/tkjuke
$PERL -ne "s+JUKE_ROOT+$JUKE_ROOT+g; print"                                    Jukebox.pm > $blib_root/Jukebox.pm
cp juke.config* $blib_root/
cp Proc/*   $blib_root/Proc/
cp Tk/ExecuteCommand.pm  $blib_root/Tk/
cp Tk/CollapsableFrame.pm  $blib_root/Tk/
cp Tk/JukeboxSlot.pm  $blib_root/Tk/
cp Tk/JukeboxDrive.pm  $blib_root/Tk/
chmod -R 744 $blib_root
chmod    755 $blib_root/juke
chmod    755 $blib_root/tkjuke
END

    print " (system error=$?) " if $?;
    print " done.\n";

    print "\nConfiguration is complete.\n\n";

} # end configure

sub get {
    my ($def, $prompt) = @_;
    chomp $prompt;
    print "\n$prompt [$def]: ";
    my $ans = <STDIN>;
    chomp $ans;
    return $ans eq '' ? $def : $ans;
}
