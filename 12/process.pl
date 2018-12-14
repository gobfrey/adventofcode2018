#!/usr/bin/perl

use strict;
use warnings;


open FILE, "input.txt";
my @lines = <FILE>;

my $garden = load_garden($lines[0]);
my $state_map = load_state_map(@lines);

output_garden($garden);
for my $i (1 .. 107)
{
	$garden = step($garden);
	print $i;
	output_garden($garden);
}

#107  9 -> 205: ##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##...##

#total = 50000000000 (50000000000 - 102) -> (50000000000 + 98)

my ($low, $high) = garden_borders($garden);
my $sum = 0;
foreach my $i ($low .. $high)
{
	if (get_plant($garden, $i) eq '#')
	{
		$sum += (50000000000 - 98) + ($i - $low)
	}
}


print "SUM: $sum\n";

sub output_garden
{
	my ($garden) = @_;

	my ($low, $high) = garden_borders($garden);

	print "  $low -> $high: ";
	foreach my $i ($low .. $high)
	{
		print get_plant($garden, $i);
	}
	print "\n";
}



sub step
{
	my ($garden) = @_;

	my $new_garden = {};

	my ($low, $high) = garden_borders($garden);

	foreach my $i ($low-4 .. $high+4)
	{
		if (plant_lives($garden, $i))
		{
			$new_garden->{$i} = '#';
		}
	}
	return $new_garden;
}

sub plant_lives
{
	my ($garden, $position) = @_;;

	my $five_plants = '';
	foreach my $i ($position-2 .. $position+2)
	{
		$five_plants .= get_plant($garden, $i);
	}
	die "unrecognised state $five_plants\n" if (!$state_map->{$five_plants});
	return 1 if ($state_map->{$five_plants} eq '#');
	return 0;
}

sub get_plant
{
	my ($garden, $i) = @_;

	return '.' if !$garden->{$i};
	return $garden->{$i};
}

sub garden_borders
{
	my ($garden) = @_;

	my @indexes = sort {$a <=>$b} keys %{$garden};

	my $lowest = shift(@indexes);
	my $highest = pop(@indexes);

	return ($lowest, $highest);
}

sub load_garden
{
	my ($line) = @_;

	if ($line =~ m/^initial state: (.*)/)
	{

		my @plants = split(//,$1);

		my $garden = {};
		foreach my $i (0 .. $#plants)
		{
			$garden->{$i} = $plants[$i];
		}
		return $garden;
	}
}

sub load_state_map
{
	my (@lines) = @_;

	my $map = {};

	foreach my $line (@lines)
	{
		if ($line =~ m/([\.#]{5}) => ([\.#])/)
		{
			$map->{$1} = $2;
		}
	}
	return $map;
}



