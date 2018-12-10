#!/usr/bin/perl

use strict;
use warnings;

open FILE, "input.txt" or die;

my $fs = {};
my $f = 0;
my @changes = <FILE>;

while (1)
{
foreach (@changes)
{
	if (m/([+-])([0-9]+)/)
	{
		if ($1 eq '-')
		{
			$f -= $2;
		}
		else
		{
			$f += $2;
		}
	}
	if ($fs->{$f})
	{
		print "Second time at $f\n";
		exit;
	}
	$fs->{$f}++

}
}

print "$f\n";

