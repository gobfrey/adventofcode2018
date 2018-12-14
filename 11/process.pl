#!/usr/bin/perl

use strict;
use warnings;
use Data::Compare;

my $GRID_SERIAL_NUMBER = 7689;

my $cells = construct_grid();
my $largest_minigrid = largest_any_size_minigrid($cells,3);
use Data::Dumper;
print STDERR Dumper $largest_minigrid;

#test_power_level();
#test_largest_minigrid();
test_minigrid_total();

#print STDERR Dumper $cells;


sub construct_grid
{
	my $cells = {};
	foreach my $x (1 .. 300)
	{
		foreach my $y (1 .. 300)
		{
			$cells->{$x}->{$y} = cell_power_level($x,$y)
		}
	}
	return $cells;
}

sub largest_any_size_minigrid
{
	my ($grid) = @_;

	my $largest;
	foreach my $n (1 .. 300)
	{
		my $l = largest_minigrid($grid, $n);
		print STDERR "$n\n";
		use Data::Dumper; print STDERR Dumper $l;

		$largest = $l unless $largest;

		if ($l->{total} > $largest->{total})
		{
			$largest = $l;
		}
	}
	return $largest;
}


sub largest_minigrid
{
	my ($grid, $grid_size) = @_;


	my $largest_minigrid = { x => 1, y => 1, total => 0};
	foreach my $x (1 .. 300)
	{
		foreach my $y (1 .. 300)
		{
			my $total = minigrid_total($grid, $x, $y, $grid_size);
			next unless defined $total;
			if ($total > $largest_minigrid->{total})
			{
				$largest_minigrid = {
					x => $x,
					y => $y,
					grid_size => $grid_size,
					total => $total
				};
			}
		}
	}
	return $largest_minigrid;
}


sub minigrid_total
{
	my ($grid, $x_top, $y_left, $grid_size) = @_;

	my $offset = $grid_size - 1;

	#check bottom right corner exists
	return undef unless (
		exists $grid->{$x_top + $offset}
		&& exists $grid->{$x_top + $offset}->{$y_left + $offset}
	);

	my $total = 0;
	foreach my $x ( $x_top .. $x_top + $offset )
	{
		foreach my $y ( $y_left .. $y_left + $offset )
		{
			my $n = $grid->{$x}->{$y};
			$total += $n;
		}
	}
	return $total;
}

sub test_minigrid_total
{
	$GRID_SERIAL_NUMBER = 18;
	my $grid = construct_grid();
	my $total = minigrid_total($grid, 33,45,3);
	print STDERR "Testing minigrid -- expecting 29, got $total\n" unless $total == 29;

	my $largest_minigrid = largest_minigrid($grid,3);
	use Data::Dumper;
	print STDERR Dumper $largest_minigrid;

	$largest_minigrid = largest_minigrid($grid,16);
	use Data::Dumper;
	print STDERR Dumper $largest_minigrid;
}

sub test_power_level
{
	my $test_data = [
		[ [3,5], 8, 4],
		[ [122,79], 57, -5],
		[ [217,196], 39, 0],
		[ [101,153], 71, 4]
	];
	foreach my $t (@{$test_data})
	{
		$GRID_SERIAL_NUMBER = $t->[1];
		my $p = cell_power_level(@{$t->[0]});
		if ($p != $t->[2])
		{
			use Data::Dumper; print STDERR Dumper $t;
			print "...returned $p\n";
		}
	}

}

sub cell_power_level
{
	my ($x, $y) = @_;

	my $rack_id = $x + 10;
	my $power_level = $rack_id * $y;
	$power_level += $GRID_SERIAL_NUMBER;
	$power_level *= $rack_id;

	my @digits = reverse split(//,'000' . $power_level);

	$power_level = $digits[2];
	$power_level -= 5;

	return $power_level;
}

