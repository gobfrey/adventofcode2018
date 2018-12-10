#!/usr/bin/perl

use strict;
use warnings;

open FILE, "input.txt";

my $fabric = {};

my @input = <FILE>;

foreach my $input (@input)
{
	if ($input =~ m/([0-9]+),([0-9]+): ([0-9]+)x([0-9]+)/)
	{
		my $coordinates = all_coordinates($1,$2,$3,$4);
		foreach my $c (@{$coordinates})
		{
			$fabric->{$c->[0]}->{$c->[1]}++;
		}
	}
}

my $overlap_count = 0;
foreach my $x (sort keys %{$fabric})
{
	foreach my $y (sort keys %{$fabric->{$x}})
	{
		$overlap_count++ if $fabric->{$x}->{$y} > 1;
	}
}

print $overlap_count, "\n";

foreach my  $input (@input)
{
	if ($input =~ m/([0-9]+),([0-9]+): ([0-9]+)x([0-9]+)/)
	{
		my $coordinates = all_coordinates($1,$2,$3,$4);
		my $found = 1;
		foreach my $c (@{$coordinates})
		{
			if ($fabric->{$c->[0]}->{$c->[1]} > 1)
			{
				$found = 0;
				last;
			}
		}
		if ($found)
		{
			print "$input\n";
		}
	}
}



sub all_coordinates
{
	my ($x,$y,$w,$h) = @_;

	my $coordinates = [];

	for my $i ($x .. (($x + $w) -1))
	{
		for my $j ($y .. (($y + $h) -1))
		{
			push @{$coordinates}, [ $i, $j ];
		}
	}

	return $coordinates;
}

