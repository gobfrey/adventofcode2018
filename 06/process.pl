#!/usr/bin/perl

use strict;
use warnings;
use Date::Calc qw(Add_Delta_DHMS);

open FILE, "input.txt";

my @input = <FILE>;

my @coords = ();
my $infinite_ids = {}; #ones that have areas on the border
my $cell_counts = {};
my $total_distances = {};

my $LARGEST_X = 0;
my $LARGEST_Y = 0;
foreach my $line (@input)
{
	if ($line =~ m/([0-9]+), ([0-9]+)/)
	{
		my ($x, $y) = ($1, $2);
		$LARGEST_X = $x if $x > $LARGEST_X;
		$LARGEST_Y = $y if $y > $LARGEST_Y;
		push @coords, [$x,$y];
	}
}

foreach my $x (0 .. $LARGEST_X)
{
	foreach my $y (0 .. $LARGEST_Y)
	{
print STDERR "$x, $y: ";
		my $area_id = get_nearest($x, $y);
		$total_distances->{$x}->{$y} = get_total_distance($x, $y);
print STDERR $total_distances->{$x}->{$y} . "\n";
		next if ($area_id eq 'tie');
		if (on_edge($x, $y))
		{
			$infinite_ids->{$area_id} = 1;
			#register as ignorable
		}
		$cell_counts->{$area_id}++;

	}
}

foreach my $id (sort keys %{$cell_counts})
{
	next if $infinite_ids->{$id};
	print "$id: " . $cell_counts->{$id} . "\n";
}

my $within_count = 0;
foreach my $x (keys %{$total_distances})
{
	foreach my $y (keys %{$total_distances->{$x}})
	{
		if ($total_distances->{$x}->{$y} < 10000)
		{
			$within_count++;
		}
	}
}
print "Within: $within_count\n";





sub on_edge
{
	my ($x, $y) = @_;

	return 1 if $x == 0;
	return 1 if $y == 0;
	return 1 if $x == $LARGEST_X;
	return 1 if $y == $LARGEST_Y;

	return 0;
}

sub get_total_distance
{
	my ($x1, $y1) = @_;

	my $total_distance = 0;

	for my $id (0 .. $#coords)
	{
		my ($x2, $y2) = @{$coords[$id]};

		my $d = taxicab_distance($x1, $y1, $x2, $y2);
		$total_distance += $d;
	}
	return $total_distance;
}

sub get_nearest
{
	my ($x1, $y1) = @_;

	my $distances = {};

	my $smallest_distance = 99999;
	for my $id (0 .. $#coords)
	{
		my ($x2, $y2) = @{$coords[$id]};

		my $d = taxicab_distance($x1, $y1, $x2, $y2);
		$distances->{$id} = $d;
		$smallest_distance = $d if $d < $smallest_distance;
	}

	my $count = 0;
	my $closest_id;
	foreach my $id (keys %{$distances})
	{
		if ($distances->{$id} == $smallest_distance)
		{
			$closest_id = $id;
			$count++;
		}
	}

	if ($count > 1)
	{
		return 'tie';
	}

	return $closest_id;
}

sub taxicab_distance
{
	my ($x1, $y1, $x2, $y2) = @_;

	abs($x1 - $x2) + abs($y1 - $y2);
}

