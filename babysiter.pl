#!/usr/bin/perl

use strict;
use warnings;

our $VERSION=0.01;

=begin comment
Jan Labanowski, janl@speakeasy.net, Sun, Feb 01, 2015  9:20:23 PM

Babysitter Kata
 
Background
----------
This kata simulates a babysitter working and getting paid for one night.
The rules are pretty straight forward:
 
The babysitter
- starts no earlier than 5:00PM
- leaves no later than 4:00AM
- gets paid $12/hour from start-time to bedtime # I assume 9pm is a bedtime
- gets paid $8/hour from bedtime to midnight
- gets paid $16/hour from midnight to end of job
- gets paid for full hours (no fractional hours)
  # I assume that even if babysitter leaves at 3:59am hs/she is paid only
  # until 3:00am
 
 
Feature:
As a babysitter
In order to get paid for 1 night of work
I want to calculate my nightly charge 
=end comment
=cut

my %time_slots = (
    'Time before bed time' =>  {  price => 12.0,
				  slot_starts => '5pm' },
    'Time after bed time' => { price => 8.0,
			       slot_starts => '9pm' },
    'After quitting time' => {  price => 0.0,
				slot_starts => '4am'  },
    );

my $Usage = qq{Given the babysiter time in and time out, the script computes
the earnings with the following assumptions: 
The babysitter
  - starts no earlier than 5:00PM
  - leaves no later than 4:00AM
  - gets paid \$12/hour from start-time to bedtime
  - gets paid \$8/hour from bedtime to midnight
  - gets paid \$16/hour from midnight to end of job
  - gets paid for full hours (no fractional hours)
The bed time starts at 9pm. For example:
  $0  5:30pm  3:30am
};

my $time_in = shift @ARGV || die $Usage;
my $time_out = shift @ARGV || die $Usage;

if(t2h($time_in) >= t2h($time_out)) {
    die "The babysitting time in ($time_in) is at or after the time out ($time_out)\n";
}

my $earliest_time = $time_slots{'Time before bed time'}->{slot_starts};
my $latest_time = $time_slots{'After quitting time'}->{slot_starts};

if((t2h($time_in) < t2h($earliest_time))
   or ($time_in =~ /am\s*$/i)) { # 5pm

    print STDERR "Dear Babysitter. You will only be paid from $earliest_time\n";
    $time_in = $earliest_time;
}

if(t2h($time_out) > t2h($latest_time)) { #4am
    print STDERR "Dear Babysitter. You will only be paid until $latest_time\n";
    $time_out = $latest_time;
}

my $last_processed =  $time_out;
my $total_amount = 0.0;

for my $slot_name ( 'After quitting time',
		    'Time after bed time', 
		    'Time before bed time' ) {

    my $slot_start_time = $time_slots{$slot_name}->{slot_starts};

    if(t2h($time_in) > t2h($slot_start_time))  {
	$slot_start_time = $time_in;
    }

    my $time_within_slot =  t2h($last_processed) - 
	t2h($slot_start_time);

    if($time_within_slot > 0) {
	my $amount_for_this_slot = 
	    $time_within_slot * $time_slots{$slot_name}->{price};
	$total_amount += $amount_for_this_slot;
	$last_processed = $time_slots{$slot_name}->{slot_starts};
    }
    if($slot_start_time eq $time_in) {
	last;
    }
}

print STDOUT "Babysitter pay for the period: $time_in -- $time_out is \$$total_amount\n";


# takes time in HH:MM[ap]m format and returns number of hours from midnight
# of the day when babysitting started (assuming that it started before
# midnight. If the time if fractional and includes minutes, returns 
# full hours only
sub t2h { 
    my $hh_mm_apm = shift @_;

    $hh_mm_apm =~ s/\s+//gs;
    my ($hh, $mm, $apm);
    if($hh_mm_apm =~ /^(\d+):?(\d\d)?([ap]m)$/i) {
	$hh = $1;
	$mm = $2 || 0;
	$apm = lc($3);
    }
    else {
	die "The time entry $hh_mm_apm is invalid. Please use standard notation HH:MMam or HH:MMpm\n";
    }
    if(($hh > 12) or ($mm > 59)) {
	die "The  time entry $hh_mm_apm is invalid. Hour ($hh) or minutes($mm) is out of range\n";
    }
    if($hh == 12) {
	$hh = 0;
    }
    my $since_midnight = $apm eq 'am' ? 12 : 0;
    my $total_hours = $hh + int($mm/60 + 0.001) + $since_midnight;
#    print STDOUT "&&& Total hours: $total_hours\n";
    return $total_hours;
}

    

