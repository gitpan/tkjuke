$Tk::JukeboxDrive::VERSION = 'VERNUM';

package Tk::JukeboxDrive;

# Jukebox tape drive widget derived from Tk::JukeboxSlot.

use base qw/Tk::Derived Tk::JukeboxSlot/;
use strict;

Construct Tk::Widget 'JukeboxDrive';

our $eject;			# image of an eject control

sub ClassInit {

    my($class, $mw) = @_;
    $class->SUPER::ClassInit($mw);

    my $xbm = <<'EJECT';
#define eject_width 32
#define eject_height 32
static unsigned char eject_bits[ = {
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00,
  0x00, 0xc0, 0x01, 0x00, 0x00, 0xe0, 0x03, 0x00, 0x00, 0xf0, 0x07, 0x00,
  0x00, 0xf8, 0x0f, 0x00, 0x00, 0xfc, 0x1f, 0x00, 0x00, 0xfe, 0x3f, 0x00,
  0x00, 0xff, 0x7f, 0x00, 0x80, 0xff, 0xff, 0x00, 0xc0, 0xff, 0xff, 0x01,
  0xe0, 0xff, 0xff, 0x03, 0xf0, 0xff, 0xff, 0x07, 0xf8, 0xff, 0xff, 0x0f,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xf8, 0xff, 0xff, 0x0f,
  0xf8, 0xff, 0xff, 0x0f, 0xf8, 0xff, 0xff, 0x0f, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, };
EJECT
    
    $eject = $mw->Bitmap(-data => $xbm)

} # end ClassInit


sub Populate {

    my($self, $args) = @_;

    $self->SUPER::Populate($args);

    $self->{mail}->packForget;
    my $b = $self->Component('Button' => 'button', -image => $eject);
    $b->pack(qw/-side bottom -fill both -expand 1/);

    $self->ConfigSpecs(
        -drivenumber => '-slotnumber',
        -width       => [ 'CHILDREN', qw/width    Width           4/ ],
    );

} # end Populate

1;
