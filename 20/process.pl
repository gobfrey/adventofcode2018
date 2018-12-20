#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my @input = load_data();

my $tree = create_node(\@input);

my $map = create_map($tree);

output_map($map);

my $distances = find_distances($map);

my $longest_distance = 0;
my $far_rooms_count = 0;
foreach my $x (keys %{$distances})
{
	foreach my $y (keys %{$distances->{$x}})
	{
		my $d = $distances->{$x}->{$y};
		$longest_distance = $d if $d > $longest_distance;
		$far_rooms_count++ if $d >= 1000;
	}
}

print "Longest: $longest_distance\n";
print "$far_rooms_count rooms further than 999\n";

sub find_distances
{
	my ($map) = @_;

	my $boundaries = get_boundaries($map);
	my $distances = {};
	$distances->{0}->{0} = 0;

	my $change = 1;

	while ($change)
	{
		$change = 0;

		foreach my $y ($boundaries->{min_y} .. $boundaries->{max_y})
		{
			foreach my $x ($boundaries->{min_x} .. $boundaries->{max_x})
			{
				if (is_room($map, $x, $y))
				{
					my $dist = calculate_distance($map, $distances, $x, $y);
					if ($dist)
					{
print STDERR "$dist\n";
						$distances->{$x}->{$y} = $dist;
						$change = 1;
					}
				}
			}
		}
	}
	return $distances;
}

sub calculate_distance
{
	my ($map, $distances, $x, $y) = @_;

	return undef if ($distances->{$x}->{$y});

	my $neighbours = get_neighbours($map,$x,$y);

	my $lowest_neighbour;
	foreach my $neighbour (@{$neighbours})
	{
		my ($n_x, $n_y) = @{$neighbour};
		if (defined $distances->{$n_x} && defined $distances->{$n_x}->{$n_y})
		{
			my $d = $distances->{$n_x}->{$n_y};
			$lowest_neighbour = $d if !defined $lowest_neighbour;
			$lowest_neighbour = $d if $d < $lowest_neighbour;
		}	
	}
	if (defined $lowest_neighbour)
	{
		return $lowest_neighbour + 1;
	}
	return undef;
}


sub get_neighbours
{
	my ($map, $x, $y) = @_;

	my $neighbours = [];

	if (
		is_door($map, $x-1, $y)
		&& is_room($map, $x-2, $y)
	)
	{
		push @{$neighbours}, [$x-2, $y];
	}
	if (
		is_door($map, $x+1, $y)
		&& is_room($map, $x+2, $y)
	)
	{
		push @{$neighbours}, [$x+2, $y];
	}
	if (
		is_door($map, $x, $y+1)
		&& is_room($map, $x, $y+2)
	)
	{
		push @{$neighbours}, [$x, $y+2];
	}
	if (
		is_door($map, $x, $y-1)
		&& is_room($map, $x, $y-2)
	)
	{
		push @{$neighbours}, [$x, $y-2];
	}

	return $neighbours;
}

sub is_door
{
	my ($map, $x, $y) = @_;

	return 0 unless $map->{$x}->{$y};
	return 1 if $map->{$x}->{$y} eq '|';
	return 1 if $map->{$x}->{$y} eq '-';
}

sub is_room
{
	my ($map, $x, $y) = @_;

	return 0 unless $map->{$x}->{$y};
	return 1 if $map->{$x}->{$y} eq '.';
	return 1 if $map->{$x}->{$y} eq 'X';
}

sub output_map
{
	my ($map) = @_;

	my $boundaries = get_boundaries($map);

	foreach my $y ($boundaries->{min_y} .. $boundaries->{max_y})
	{
		foreach my $x ($boundaries->{min_x} .. $boundaries->{max_x})
		{
			print $map->{$x}->{$y} ? $map->{$x}->{$y} : ' ';
		}
		print "\n";
	}
	print "\n";
}


sub create_map
{
	my ($directions) = @_;

	my $map = {};
	my $x = 0;
	my $y = 0;
	$map->{$x}->{$y} = 'X';

	foreach my $alternative_route (@{$directions})
	{
		walk_path($map, $directions, $x, $y);
	}
	fill_in_walls($map);
	return $map;
}

sub fill_in_walls
{
	my ($map) = @_;

	my $boundaries = get_boundaries($map);

	foreach my $y ($boundaries->{min_y}-1 .. $boundaries->{max_y}+1)
	{
		foreach my $x ($boundaries->{min_x}-1 .. $boundaries->{max_x}+1)
		{
			$map->{$x}->{$y} = '#' unless $map->{$x}->{$y};
		}
	}
}

sub get_boundaries
{
	my ($map) = @_;

	my @all_x = sort {$a <=> $b} keys %{$map};
	my $min_x = $all_x[0];
	my $max_x = $all_x[$#all_x];

	my $min_y = 0; # 0 is the centre
	my $max_y = 0; # 0 is the centre
	foreach my $x ($min_x .. $max_x)
	{
		foreach my $y (keys %{$map->{$x}})
		{
			$min_y = $y if $y < $min_y;
			$max_y = $y if $y > $max_y;
		}
	}

	return { min_x => $min_x, max_x => $max_x, min_y => $min_y, max_y => $max_y };
}


sub walk_path
{
	my ($map, $directions, $x, $y) = @_;

	foreach my $d (@{$directions})
	{
		if (ref($d) eq 'ARRAY')
		{
			walk_path($map, $d, $x, $y);
		}
		elsif ($d eq 'N')
		{
			$map->{$x}->{$y-1} = '-';
			$map->{$x}->{$y-2} = '.';
			$y-=2;
		}
		elsif ($d eq 'S')
		{
			$map->{$x}->{$y+1} = '-';
			$map->{$x}->{$y+2} = '.';
			$y+=2;
		}
		elsif ($d eq 'E')
		{
			$map->{$x+1}->{$y} = '|';
			$map->{$x+2}->{$y} = '.';
			$x+=2;
		}
		elsif ($d eq 'W')
		{
			$map->{$x-1}->{$y} = '|';
			$map->{$x-2}->{$y} = '.';
			$x-=2;
		}
	}
}



sub create_node
{
	my ($chars) = @_;

	my $node = [];

	my $path = [];	
	push @{$node}, $path;

	while (1)
	{
		my $char = shift @{$chars};

		return $node if ($char eq ')' or $char eq '$');
	
		push @{$path}, create_node($chars) if $char eq '(';

		push @{$path}, $char if $char =~ m/[NSEW]/;

		if ($char eq '|')
		{
			$path = [];
			push @{$node}, $path;
		}
	}

}

sub load_data
{
	open FILE, "input.txt" or die "couldn't open index.txt";

	my @input = <FILE>;

	return split(//,join('',@input));
}

sub load_test_data
{
	return split(//,'^WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))$');

}
