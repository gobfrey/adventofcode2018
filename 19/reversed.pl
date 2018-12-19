#!/usr/bin/perl

use strict;
use warnings;


my $const = 10551367;
#my $const = 967;

my $result = 0;
my $tick1 = 1;
my $tick4 = 1;


while (1)
{
	if ($const % $tick1 == 0)
	{
		$result += $tick1;
	}

	$tick1++;

	if ($tick1 > $const)
	{
		last;
	}
}

print "$result\n";



