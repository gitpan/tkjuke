
# Install the "mtx" "juke" command for Unix. Simply initialize PERL
# and PREFIX as desired and run this program. Continue with the remaining
# steps detailed in the file INSTALL.

PERL=/usr/local/bin/perl
PREFIX=/usr/local

# No other changes should be required below.

VERNUM='1.0.5'
JUKE_ROOT=$PREFIX/tkjuke/$VERNUM
JUKE_EXE=$JUKE_ROOT/juke

mkdir $PREFIX/tkjuke  2> /dev/null
mkdir $JUKE_ROOT      2> /dev/null
mkdir $JUKE_ROOT/Proc 2> /dev/null
mkdir $JUKE_ROOT/Tk   2> /dev/null

$PERL -ne "s+JUKE_ROOT+$JUKE_ROOT+g; s+PERL+$PERL+; print"                           juke > $JUKE_EXE
$PERL -ne "s+JUKE_ROOT+$JUKE_ROOT+g; s+PERL+$PERL+; s+JUKE_EXE+$JUKE_EXE+g; print" tkjuke > $JUKE_ROOT/tkjuke
$PERL -ne "s+JUKE_EXE+$JUKE_EXE+g;                      print"                juke.config > $JUKE_ROOT/juke.config
$PERL -ne "s+JUKE_EXE+$JUKE_EXE+g;                      print"                juke.config.rigel > $JUKE_ROOT/juke.config.rigel
$PERL -ne "s+JUKE_ROOT+$JUKE_ROOT+g; s+VERNUM+$VERNUM+; print"                 Jukebox.pm > $JUKE_ROOT/Jukebox.pm
$PERL -ne "s+VERNUM+$VERNUM+; print"                                    Tk/JukeboxSlot.pm > $JUKE_ROOT/Tk/JukeboxSlot.pm
$PERL -ne "s+VERNUM+$VERNUM+; print"                                   Tk/JukeboxDrive.pm > $JUKE_ROOT/Tk/JukeboxDrive.pm
cp                                                                                 Proc/*   $JUKE_ROOT/Proc/
cp                                                                    Tk/ExecuteCommand.pm  $JUKE_ROOT/Tk/
cp                                                                    Tk/CollapsableFrame.pm  $JUKE_ROOT/Tk/

chmod -R 744 $JUKE_ROOT
chmod    755 $JUKE_ROOT/juke
chmod    755 $JUKE_ROOT/tkjuke
