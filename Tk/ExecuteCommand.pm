$Tk::ExecuteCommand::VERSION = '1.5';

package Tk::ExecuteCommand;

use IO::Handle;
use Proc::Killfam;
use Tk::widgets qw/LabEntry ROText/;
use base qw/Tk::Frame/;
use strict;

Construct Tk::Widget 'ExecuteCommand';

sub Populate {

    my($self, $args) = @_;

    $self->SUPER::Populate($args);

    my $f1 = $self->Frame->pack;
    my $c = $f1->LabEntry->pack(qw/-side left/);
    $self->Advertise('command' => $c);

    my $doit = $f1->Button->pack(qw/-side left/);
    $self->Advertise('doit' => $doit);
    $self->_reset_doit_button;

    $c->bind('<Return>' => [$doit => 'invoke']);

    my $s = $self->Frame->pack(qw/-pady 10/);
    $self->Advertise('spacer' => $s);
    my $l = $self->Label(-text => 'Command\'s stdout and stderr')->pack;
    $self->Advertise('label' => $l);

    my $text = $self->Scrolled('ROText');
    $text->pack(qw/-expand 1 -fill both/); 
    $self->Advertise('text' => $text);
    $self->OnDestroy( sub { killfam 'TERM', $self->{-pid} if defined $self->{-pid} } );

    $self->{-finish} = 0;
    $self->{-tid} = undef;
    $self->{doit_text} = 'Do It!';

    $self->ConfigSpecs(
        -command      => [qw/METHOD command     Command/,     'sleep 5; pwd' ],
        -entryWidth   => [{-width => $c}, qw/entryWidth      EntryWidth  10/ ],
        -height       => [$text,   qw/height    Height                   24/ ],
        -label        => [$c,      qw/label     Label/, 'Command to Execute' ],
        -labelPack    => [$c,      qw/labelPack LabelPack/,  [-side=>'left'] ],
        -scrollbars   => [$text,   qw/scrollbar Scrollbar                sw/ ],
        -text         => [qw/METHOD text        Text/,    $self->{doit_text} ],
        -textvariable => [$c,qw/textvariable Textvariable/,\$self->{-command}],
        -width        => [$text,   qw/width     Width                    80/ ],
        -wrap         => [$text,   qw/wrap      Wrap/,                'none' ],
    );

} # end Populate

sub command {

    my($self, $command) = @_;
    $self->{-command} = $command;

} # end command

sub _flash_doit {

    # Flash "Do It" by alternating its background color.

    my($self, $option, $val1, $val2, $interval) = @_;

    if ($self->{-finish} == 0) {
	$self->Subwidget('doit')->configure($option => $val1);
	$self->idletasks;
	$self->{-tid} = $self->after($interval,
	    [\&_flash_doit, $self, $option, $val2, $val1, $interval]);
    }

} # end _flash_doit

sub _read_stdout {

    # Called when input is available for the output window.  Also checks
    # to see if the user has clicked Cancel.

    my($self) = @_;

    if ($self->{-finish}) {
	$self->kill_command;
    } else {
	my $h = $self->{-handle};
	if ( sysread $h, $_, 4096 ) {
	    my $t = $self->Subwidget('text');
	    $t->insert('end', $_);
	    $t->yview('end');
	} else {
	    $self->{-finish} = 1;
	}
    }
	
} # end _read_stdout

sub _reset_doit_button {

    # Establish normal "Do It" button parameters.

    my($self) = @_;

    my $doit = $self->Subwidget('doit');
    my $doit_bg = ($doit->configure(-background))[3];
    $doit->configure(
        -text       => $self->{doit_text},
        -relief     => 'raised',
        -background => $doit_bg,
        -state      => 'normal',
        -command    => [sub {
	    my($self) = @_;
            $self->Subwidget('doit')->configure(
                -text   => 'Working ...',
                -relief => 'sunken',
                -state  => 'disabled'
            );
            $self->{-finish} = 0;
            $self->execute_command;
        }, $self],
    );

    $self->{-finish} = 0;

} # end _reset_doit_button

sub text {

    my($self, $text) = @_;
    $self->{doit_text} = $text;
    $self->Subwidget('doit')->configure(-text => $text);

} # end text

# Public methods.

sub execute_command {

    # Execute the command and capture stdout/stderr.

    my($self) = @_;
    
    my $h = IO::Handle->new;
    die "IO::Handle->new failed." unless defined $h;
    $self->{-handle} = $h;

    $self->{-pid} = open $h, $self->{-command} . ' 2>&1 |';
    if (not defined $self->{-pid}) {
	$self->Subwidget('text')->insert('end',
            "'" . $self->{-command} . "' : $!\n");
	$self->kill_command;
	return;
    }
    $h->autoflush(1);
    $self->fileevent($h, 'readable' => [\&_read_stdout, $self]);

    my $doit = $self->Subwidget('doit');
    $doit->configure(
        -text    => 'Cancel',
        -relief  => 'raised',
        -state   => 'normal',
        -command => [\&kill_command, $self],
    );

    my $doit_bg = ($doit->configure(-background))[3];
    $self->_flash_doit(-background => $doit_bg, qw/cyan 500/);

    $self->waitVariable(\$self->{-finish});
    
} # end execute_command

sub get_status {

    # Return a 2 element array of $? and $! from last command execution.

    my($self) = @_;

    my $stat = $self->{-status};
    return (defined $stat ? @$stat : undef);

} # end get_status

sub kill_command {
    
    # A click on the blinking Cancel button resumes normal operations.

    my($self) = @_;

    $self->{-finish} = 1;
    $self->afterCancel($self->{-tid}) if defined $self->{-tid};
    my $h = $self->{-handle};
    return unless defined $h;
    $self->fileevent($h, 'readable' => ''); # clear handler
    killfam 'TERM', $self->{-pid} if defined $self->{-pid};
    close $h;
    $self->{-status} = [$?, $!];
    $self->_reset_doit_button;

} # end kill_command

sub terse_gui {

    # Remove all but ROText widget. Currently, cannot be reversed.

    my ($self) =@_;

    my $n = 0;
    foreach ($self->children) {
	if (ref($_) eq 'Tk::Frame') {
	    $n++;
	    $_->packForget if $n <= 2;
	} elsif (ref($_) eq 'Tk::Label') {
	    $_->packForget;
	}
    }

} # end terse_gui

1;

__END__

=head1 NAME

Tk::ExecuteCommand - execute a command asynchronously (non-blocking).

=for pm Tk/ExecuteCommand.pm

=for category Widgets

=head1 SYNOPSIS

 $exec = $parent->ExecuteCommand;

=head1 DESCRIPTION

Tk::ExecuteCommand runs a command yet still allows Tk events to flow.  All
command output and errors are displayed in a window.

This ExecuteCommand mega widget is composed of an LabEntry widget for
command entry, a "Do It" Button that initiates command execution, and
a ROText widget that collects command execution output.

While the command is executing, the "Do It" Button changes to a "Cancel"
Button that can prematurely kill the executing command. The B<kill_command>
method does the same thing programmatically.

=head1 OPTIONS

=over 4

=item B<-command>

The command to execute asynchronously.

=item B<-entryWidth>

Character width of command Entry widget.

=item B<-height>

Character height of the ROText widget.

=item B<-label>

Label text for command Entry widget.

=item B<-text>

Label text for "Do It!" Button.

=item B<-width>

Character width of the ROText widget.

=back

=head1 METHODS

=over 4

=item $exec->execute_command;

Initiates command execution.

=item $exec->get_status;

Returns a 2 element array of $? and $! from last command execution.

=item $exec->kill_command;

Terminates the command.  This subroutine is called automatically via an
OnDestroy handler when the ExecuteCommand widget goes away.

=item $exec->terse_gui;

packForgets all but the minimal ROText widget.  Currently, this action
cannot be rescinded.

=back

=head1 ADVERISED SUBWIDGETS

Component subwidgets can be accessed via the B<Subwidget> method.
Valid subwidget names are listed below.

=over 4

=item Name:  command, Class: LabEntry

Refers to the command LabEntry widget.

=item Name: doit, Class: Button

Refers to the command execution Button.

=item Name: spacer, Class: Frame

Refers to the spacer Frame separating the Entry and ROText widgets.

=item Name: label, Class: Label

Refers to the Label across the top of the ROText widget.

=item Name: text, Class: ROText

Refers to the ROText widget that collects command execution output.

=back

=head1 EXAMPLE

 $ec = $mw->ExecuteCommand(
     -command    => '',
     -entryWidth => 50,
     -height     => 10,
     -label      => '',
     -text       => 'Execute',
 )->pack;
 $ec->configure(-command => 'mtx -f /dev/sch0 load 1 0');
 $ec->execute_command;
 $ec->bell;
 $ec->update;

=head1 KEYWORDS

exec, command, fork, asynchronous, non-blocking, widget

=head1 COPYRIGHT

Copyright (C) 1999 - 2006 Stephen O. Lidie. All rights reserved.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

