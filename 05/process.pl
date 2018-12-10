#!/usr/bin/perl

use strict;
use warnings;
use Date::Calc qw(Add_Delta_DHMS);

open FILE, "input.txt";

my @input = <FILE>;

chomp $input[0];
my @letters = split(//,$input[0]);


my $letter_counts = {};
foreach my $letter ('a' .. 'z')
{
	my $count = reduce_and_count(remove_letter($letter, @letters));
	$letter_counts->{$letter} = $count;
	print STDERR "$letter -> $count\n";
}


sub remove_letter
{
	my ($letter, @letters) = @_;

	my @copy;
	foreach my $l (@letters)
	{
		push @copy, $l if lc($l) ne lc($letter);
	}
	return @copy;
}

sub reduce_and_count
{
	my (@letters) = @_;

	while (1)
	{
		my $count = scalar @letters;
		foreach my $i (1 .. $#letters)
		{
			last if ($i > $#letters);
			if (
				(lc($letters[$i]) eq lc($letters[$i-1]))
				&& ($letters[$i] ne $letters[$i-1])
			)
			{
#				print STDERR "Bef: " . $letters[$i-2], $letters[$i-1], $letters[$i], $letters[$i+1], $letters[$i+2] ."\n";
				splice(@letters, $i-1, 2);
#				print STDERR "Now: " . $letters[$i-2], $letters[$i-1], $letters[$i], $letters[$i+1], $letters[$i+2] ."\n";
			}
		}
		return $count if $count == scalar @letters;
	}
}
