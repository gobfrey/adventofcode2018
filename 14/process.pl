#!/usr/bin/perl

use strict;
use warnings;

my $target = "824501";

#$target = "01245";
my @target_digits = split(//,$target);
my $target_digit_index = 0;
my $node_count = 2;

my $a = { score => 3 };
my $b = { score => 7};
$a->{next} = $b;

my $count = 2;

my $first = $a;
my $last = $b;

while (1)
{
	add_recipe();
	move_elves();
#output();
	print "$count\n";
#	output_ten_after($count - 10);
}

sub output_ten_after
{
	my ($target) = @_;

	my $node = $first;
	foreach (1 .. $target)
	{
		$node = $node->{next};
	}

	foreach (1 .. 10)
	{
		print $node->{score};
		$node = $node->{next};
		last unless $node;
	}
	print "\n";

}


sub output
{
	my $node = $first;

	while (1)
	{
		print $node->{score} . ' ';
		$node = $node->{next};
		last unless $node;
	}
	print "\n";
}

sub add_recipe
{
	my @score = split(//, $a->{score} + $b->{score});

	foreach my $s (@score)
	{
		my $new = { score => $s };
		$last->{next} = $new;
		$last = $new;

		$count++;

		my $t = $target_digits[$target_digit_index];
		if ($s == $t)
		{
			if ($target_digit_index == $#target_digits)
			{
				print "Found Target\n -- last ditit at $count, last non-target digit at " . ($count - $target_digit_index - 1) . "\n";
				exit;
			}
			$target_digit_index++;
		}
		else
		{
			$target_digit_index = 0;
			my $t = $target_digits[$target_digit_index];
			$target_digit_index++ if ($s == $t)
		}


	}
}

sub move_elves
{
	for (1 .. $a->{score} + 1)
	{
		$a = $a->{next};
		$a = $first if (!$a);
	}

	for (1 .. $b->{score} + 1)
	{
		$b = $b->{next};
		$b = $first if (!$b);
	}
}


