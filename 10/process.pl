#!/usr/bin/perl

use strict;
use warnings;
use Data::Compare;

#my @input = parse_input(test_data());
my @input = parse_input(get_input());

#test_input(@input);
#test_step();

output_message(@input);

foreach my $i (1 .. 20000)
{
	step_lights(@input);
print "$i\n";
	output_message(@input);
}

sub output_message
{
	my (@input) = @_;

	my $coords = {};
	my $max_x = 0;
	my $max_y = 0;
	foreach my $i (@input)
	{
		my $x = $i->{position}->[0];
		my $y = $i->{position}->[1];

		$max_x = $x if $x > $max_x;
		$max_y = $y if $y > $max_y;

		$coords->{$x}->{$y} = 1;
	}

	#don't render if any max is bigger than n (arrived at through trial and error);
	print "$max_x, $max_y\n";
	return unless ($max_x < 250 && $max_y < 250);

	for my $y (0 .. $max_y)
	{
		for my $x (0 .. $max_x)
		{
			print $coords->{$x}->{$y} ? '#' : '.';
		}
		print "\n";
	}
	print "\n\n";

	sleep(1);
}

sub step_lights
{
	my (@lights) = @_;
	foreach my $l (@lights)
	{
		step_light($l);
	}
}

sub step_light
{
	my ($light) = @_;

	foreach my $i (0 .. 1)
	{
		$light->{position}->[$i] += $light->{velocity}->[$i];
	}

}

sub test_step
{
	my $test_data = [
		[
			{ position => [1,10], velocity => [2,5] },
			{ position => [3,15], velocity => [2,5] }
		],
		[
			{ position => [1,-10], velocity => [-2,5] },
			{ position => [-1,-5], velocity => [-2,5] }
		]


	];

	foreach my $pair (@{$test_data})
	{
		step_light($pair->[0]);

		die "stepping not working" unless
			Compare($pair->[0],$pair->[1]);
	}

}

sub test_input
{
	my (@input) = @_;

	die "wrong number of inputs" unless scalar @input == 31;

	die "Bad input data" unless Compare ($input[0], {position => [9,1], velocity => [0,2]});

}

sub parse_input
{
	my (@lines) = @_;

	my @input = ();

	foreach my $line (@lines)
	{
		#position=< 9,  1> velocity=<0,  2>
		if ($line =~ m/position=<\s*([0-9-]+),\s*([0-9-]+)> velocity=<\s*([0-9-]+),\s*([0-9-]+)>/)
		{
			push @input, {position => [$1,$2], velocity => [$3,$4]};
		}
	}
	return @input;
}


sub get_input
{
	open FILE, "input.txt";
	my @input = <FILE>;
}

sub test_data
{
	return (
'position=< 9,  1> velocity=< 0,  2>',
'position=< 7,  0> velocity=<-1,  0>',
'position=< 3, -2> velocity=<-1,  1>',
'position=< 6, 10> velocity=<-2, -1>',
'position=< 2, -4> velocity=< 2,  2>',
'position=<-6, 10> velocity=< 2, -2>',
'position=< 1,  8> velocity=< 1, -1>',
'position=< 1,  7> velocity=< 1,  0>',
'position=<-3, 11> velocity=< 1, -2>',
'position=< 7,  6> velocity=<-1, -1>',
'position=<-2,  3> velocity=< 1,  0>',
'position=<-4,  3> velocity=< 2,  0>',
'position=<10, -3> velocity=<-1,  1>',
'position=< 5, 11> velocity=< 1, -2>',
'position=< 4,  7> velocity=< 0, -1>',
'position=< 8, -2> velocity=< 0,  1>',
'position=<15,  0> velocity=<-2,  0>',
'position=< 1,  6> velocity=< 1,  0>',
'position=< 8,  9> velocity=< 0, -1>',
'position=< 3,  3> velocity=<-1,  1>',
'position=< 0,  5> velocity=< 0, -1>',
'position=<-2,  2> velocity=< 2,  0>',
'position=< 5, -2> velocity=< 1,  2>',
'position=< 1,  4> velocity=< 2,  1>',
'position=<-2,  7> velocity=< 2, -2>',
'position=< 3,  6> velocity=<-1, -1>',
'position=< 5,  0> velocity=< 1,  0>',
'position=<-6,  0> velocity=< 2,  0>',
'position=< 5,  9> velocity=< 1, -2>',
'position=<14,  7> velocity=<-2,  0>',
'position=<-3,  6> velocity=< 2, -1>')

;

}
