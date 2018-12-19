#!/usr/bin/perl

use strict;
use warnings;

#my @input = load_input();
my @input = load_test_input();

my $map = load_map(@input);


output_map($map);

foreach (1 .. 100)
{
	tick($map);

}

sub tick
{
	my ($map) = @_;

	my $combatants = get_combatants; #ordered list
	my ($elves, $goblins) = split_combatants($combatants);

	foreach my $combatant (@{$combatants}
	{
		attack($combatant, $elves) if $combatant->{goblin};
		attack($combatant, $goblins) if $combatant->{elf};
	}


}


sub attack
{
	my ($combatant, $enemies) = @_;

	my $enemy = first_adjacent_enemy($combatant, $enemies);
	if ($enemy)
	{
		hit($combatant, $enemy);
	}


}

sub hit
{
	my ($combatant, $enemy) = @_;

	my $damage = $combatant->{combatant}->{strength};
	$enemy->{combatant}->{hit_points} -= $damage;

	if ($enemy->{combatant}->{hit_points} <= 0)
	{
		kill
	}
}


sub split_combatants
{
	my ($combatants) = @_;

	my ($elves, $goblins} = [];

	foreach my $c (@{$combatants})
	{
		push @{$elves}, $c if $c->{elf};
		push @{$goblins}, $c if $c->{goblin};
	}
	return ($elves, $goblins);
}

sub get_combatants
{
	my ($map) = @_;

	my $combatants = [];

	my $row = 0;
	my $column = 0;
	foreach my $row (@{$map})
	{
		$column = 0;
		foreach my $cell (@{$row})
		{
			push @{$combatants},
				{goblin => $cell->{goblin}, combatant => $cell->{goblin}, row => $row, column => $column}
				if $cell->{goblin};

			push @{$combatants},
				{elf => $cell->{elf}, combatant => $cell->{elf}, row => $row, column => $column}
				if $cell->{elf};

			$column++;
		}
		$row++;
	}

}


sub output_map
{
	my ($map) = @_;

	foreach my $row (@{$map})
	{
		foreach my $cell (@{$row})
		{
			output_cell($cell);
		}
		print "\n";
	}

}

sub output_cell
{
	my ($cell) = @_;

	if ($cell->{type} eq 'wall')
	{
		print '#';
	}
	elsif ($cell->{elf})
	{
		print 'E';
	}
	elsif ($cell->{goblin})
	{
		print 'G';
	}
	elsif ($cell->{type} eq 'ground')
	{
		print '.';
	}
	else
	{
		print '!';
	}
}

sub load_map
{
	my (@input) = @_;

	my $map = [];
	foreach my $line (@input)
	{
		chomp $line;
		my $row = [];
		push @$map, $row;
		foreach my $char (split(//,$line))
		{
			push @{$row}, create_cell($char);
		}
	}
	return $map;
}

sub create_cell
{
	my ($char) = @_;

	my $cell = {};
	if ($char eq '#')
	{
		$cell->{type} = 'wall';
	}

	if ($char eq '.')
	{
		$cell->{type} = 'ground';
	}

	if ($char eq 'G')
	{
		$cell->{type} = 'ground';
		$cell->{goblin} = { hit_points => 200, strength => 3 };
	}

	if ($char eq 'E')
	{
		$cell->{type} = 'ground';
		$cell->{elf} = { hit_points => 200, strength => 3 };
	}
	return $cell;
}



sub load_input
{
	my $file = 'input.txt';
	open FILE, $file;
	return <FILE>;
}

sub load_test_input
{
	return (
'#######',
'#G..#E#',
'#E#E.E#',
'#G.##.#',
'#...#E#',
'#...E.#',
'#######'
);

}


