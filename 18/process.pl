#!/usr/bin/perl

use strict;
use warnings;

my $field = load_input();


output_field($field);

my $value_cycle = [
175715,
176700,
181178,
182479,
186124,
189846,
195650,
196384,
204129,
207030,
205882,
207570,
213321,
214968,
218880,
221880,
223862,
220735,
226380,
228760,
226450,
222390,
217160,
206957,
201474,
191475,
167700,
170328,
];


my $i = 1000000000 % 28;
print $value_cycle->[$i];
exit;

for my $i (1 .. 1000000000)
{
	$field = tick($field);
	print "After $i minutes: ";
	my $r =  resource_value($field);
	print $r;

	my $index = $i % 28;

	print 'YESSSS' if $value_cycle->[$index] == $r;

	print "-- $index  should be ";
	foreach my $j (0 .. $#{$value_cycle})
	{
		if ($value_cycle->[$j] == $r)
		{
			print $j;
		}
	}

	print "\n";

#	output_field($field);
}



sub resource_value
{
	my ($field) = @_;

	my $counts = {};
	foreach my $row (@{$field})
	{
		foreach my $acre (@{$row})
		{
			$counts->{$acre}++;
		}
	}

	return ($counts->{'|'} * $counts->{'#'});
}


sub tick
{
	my ($field) = @_;

	my $new_field = [];

	foreach my $row_number (0 .. $#{$field})
	{
		my $new_row = [];
		push @{$new_field}, $new_row;
		foreach my $acre_number (0 .. $#{$field->[$row_number]})
		{
			my $acre = $field->[$row_number]->[$acre_number];
			my $counts = count_neighbours($field, $row_number, $acre_number);

			my $new_acre = $acre;

			if (
				$acre eq '.'
				&& $counts->{'|'} >= 3
			)
			{
				$new_acre = '|';
			}
			elsif (
				$acre eq '|'
				&& $counts->{'#'} >= 3
			)
			{
				$new_acre = '#';
			}
			elsif (
				$acre eq '#'
				&& $counts->{'#'} > 0
				&& $counts->{'|'} > 0
			)
			{
				$new_acre = '#';
			}
			elsif ($acre eq '#')
			{
				$new_acre = '.';
			}


			push @{$new_row}, $new_acre;
		}
	}

	return $new_field;
}

sub count_neighbours
{
	my ($field, $row_number, $acre_number) = @_;

	my $counts =
	{
		'.' => 0,
		'|' => 0,
		'#' => 0
	};
	foreach my $r ($row_number - 1 .. $row_number + 1)
	{
		next if ($r < 0 || $r > $#{$field});
		foreach my $a ($acre_number - 1 .. $acre_number + 1)
		{
			next if ($a < 0 || $a > $#{$field->[$r]});
			next if ($r == $row_number && $a == $acre_number); #don't count the square, only the neighbours
			$counts->{$field->[$r]->[$a]}++;
		}
	}
	return $counts;
}

sub output_field
{
	my ($field) = @_;
	foreach my $row (@{$field})
	{
		foreach my $acre (@{$row})
		{
			print $acre;
		}
		print "\n";
	}
	print "\n";
}


sub load_input
{
	open FILE, 'input.txt';
	my @lines = <FILE>;

	return parse_input(@lines);
}

sub load_test_input
{
	my @test_lines = split('\n','.#.#...|#.
.....#|##|
.|..|...#.
..|#.....#
#.#|||#|#|
...#.||...
.|....|...
||...#|.#|
|.||||..|.
...#.|..|.');

	return parse_input(@test_lines);

}


sub parse_input
{
	my (@lines) = @_;

	my $field = [];

	foreach my $line (@lines)
	{
		chomp $line;
		my @acres = split(//,$line);
		push @{$field}, \@acres;
	}
	return $field;
}

