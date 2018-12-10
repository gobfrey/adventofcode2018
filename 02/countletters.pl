#!/usr/bin/perl

use strict;
use warnings;

open FILE, "input.txt";

my @input = <FILE>;

my $triples = 0;
my $doubles = 0;

foreach my $line (@input)
{
	$triples++ if has_multiple($line, 3);
	$doubles++ if has_multiple($line, 2);
}

print $triples * $doubles, "\n";

for my $i (0 .. $#input)
{
	for my $j ($i+1 .. $#input)
	{
		if (count_differences($input[$i], $input[$j]) == 1)
		{
			print $input[$i];
			print $input[$j];
			exit;
		}
	}
}


sub count_differences
{
	my ($a, $b) = @_;

	my @a = split(//,$a);
	my @b = split(//,$b);

	my $differences = 0;
	for my $i (0 .. $#a)
	{
		$differences++ if ($a[$i] ne $b[$i]);
	}
	return $differences;
}



sub has_multiple
{
	my ($string, $count) = @_;
	my $counts = count($string);

	foreach my $k (keys %{$counts})
	{
		return 1 if $counts->{$k} == $count;
	}
}

sub count
{
	my ($string) = @_;

	my @letters = split(//,$string);

	my $counts = {};

	foreach (@letters)
	{
		$counts->{$_}++;
	}

	return $counts;
}

