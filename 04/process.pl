#!/usr/bin/perl

use strict;
use warnings;
use Date::Calc qw(Add_Delta_DHMS);

open FILE, "input.txt";

my @input = <FILE>;

my $state;
my $sleeps = {};

foreach my $input (sort @input)
{
	if ($input =~ m/\[([0-9-]+ [0-9:]+)\] (.*)/)
	{
		my ($datestamp, $msg) = ($1, $2);

		if ($msg =~ m/Guard #([0-9]+) begins shift/)
		{
			if ($state)
			{
				#record state
			}
			$state = {
				guard => $1,
			};
		}

		if ($msg eq 'falls asleep')
		{
			$state->{sleep_start} = $datestamp;
		}

		if ($msg eq 'wakes up')
		{
			update_sleeps($state->{guard}, $state->{sleep_start}, $datestamp);
		}

	}
}

my $top_guard;
foreach my $guard (keys %{$sleeps})
{
	$top_guard = $guard unless $top_guard;
	$top_guard = $guard if ($sleeps->{$guard}->{total} > $sleeps->{$top_guard}->{total});
}

print "$top_guard\n";

my $top_minute;
foreach my $minute (keys %{$sleeps->{$top_guard}})
{
	next if $minute eq 'total';
	$top_minute = $minute unless $top_minute;
	$top_minute = $minute if $sleeps->{$top_guard}->{$minute} > $sleeps->{$top_guard}->{$top_minute};
}
print "$top_minute\n";

print "\n\n";
my $top_guard_2;
my $top_minute_2;
foreach my $guard (keys %{$sleeps})
{
	my $top_guard_minute;
	foreach my $minute (keys %{$sleeps->{$guard}})
	{
		next if $minute eq 'total';
		$top_guard_minute = $minute unless $top_guard_minute;
		$top_guard_minute = $minute if ($sleeps->{$guard}->{$minute} > $sleeps->{$guard}->{$top_guard_minute});
	}
	$top_guard_2 = $guard unless $top_guard_2;
	$top_minute_2 = $top_guard_minute unless $top_minute_2;

	if ($sleeps->{$guard}->{$top_guard_minute} > $sleeps->{$top_guard_2}->{$top_minute_2})
	{
		$top_guard_2 = $guard;
		$top_minute_2 = $top_guard_minute;
	}
}

print "$top_guard_2\n$top_minute_2\n";
sub update_sleeps
{
	my ($guard, $sleep_datestamp, $wake_datestamp) = @_;

	my $times_asleep = datestamps_to_minutes($sleep_datestamp, $wake_datestamp);

	$sleeps->{$guard}->{total} += scalar @{$times_asleep};
	foreach  my $t (@{$times_asleep})
	{
		$sleeps->{$guard}->{$t}++;
	}
}

sub datestamps_to_minutes
{
	my ($start, $end_plus_one) = @_;

	my $minutes = [];
	my $datestamp = $start;
	while(1)
	{
		last if $datestamp eq $end_plus_one;

		my ($date, $time) = split(/\s/, $datestamp);

		push @{$minutes}, $time;

		$datestamp = add_minute($datestamp);
	}

	return $minutes;

}

sub add_minute
{
	my ($date_time) = @_;


	if ($date_time =~ m/([0-9]{4})-([0-9]{2})-([0-9]{2}) ([0-9]{2}):([0-9]{2})/)
	{
		my ($year,$month,$day,$hour,$minute,$seconds) = ($1,$2,$3,$4,$5,0);

		my ($year2, $month2, $day2, $hour2, $minute2,) = 
   		 Add_Delta_DHMS( $year, $month, $day, $hour, $minute, $seconds,
                0, 0, 1, 0 );

		return sprintf("%04d-%02d-%02d %02d:%02d",$year2, $month2, $day2, $hour2, $minute2);
	}

}


