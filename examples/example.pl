#!/usr/bin/perl

use strict;
use Audio::AMaMP;

# Create AMaMP object.
my $amamp = Audio::AMaMP->new;

# Attempt to start core.
print "Enter path to core: ";
my $corePath = <STDIN>;
chop $corePath;
print "Enter path to instruction file: ";
my $instructionFile = <STDIN>;
chop $instructionFile;
unless ($amamp->startCore($corePath, $instructionFile)) {
	print "ERROR: Cannot start core!\n";
	exit(1);
}

# Sit in a loop taking commands.
print "Type m to view messages, d to view debug info, s to stop, q to quit followed by enter.\n> ";
while (<STDIN>) {
	chop;
	if ($_ eq 'm') {
		# Get and display messages.
		my $message;
		while ($message = $amamp->getRawMessage(0)) {
			print $message;
		}
	} elsif ($_ eq 'd') {
		# Get messages and display the debug ones.
		my %message;
		while (%message = $amamp->getMessage(0)) {
			if ($message{'type'} eq 'debug') {
				print 'The ' . $message{'parameters'}->{'module'} .
				      ' said ' . $message{'parameters'}->{'message'} . ".\n";
			}
		}
	} elsif ($_ eq 's') {
		# Send stop message.
		$amamp->sendMessage(
			type		=> 'core',
			parameters	=>
				{
				  request	=> 'stop',
				  id		=> '1234'
				}
		);
	} elsif ($_ eq 'q') {
		# Quit, but only if core has terminated.
		if ($amamp->isCoreAlive) {
			print "Core is still alive!\n";
		} else {
			exit(0);
		}
	}
	print "> ";
}
