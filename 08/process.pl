#!/usr/bin/perl

use strict;
use warnings;
use Date::Calc qw(Add_Delta_DHMS);

#my $input = test_data();
my $input = get_input();

chomp $input;
my @NUMBERS = split(/\s/,$input);
my $top_node = create_node();

use Data::Dumper;
print STDERR Dumper $top_node;

#print count_metadata($top_node) . "\n";
print count_metadata2($top_node) . "\n";

sub count_metadata2
{
	my ($node) = @_;

	my $count = 0;

	if ((scalar @{$node->{children}}) == 0)
	{
		foreach my $m (@{$node->{metadata}})
		{
			$count += $m;
		}
		return $count;
	}

	foreach my $m (@{$node->{metadata}})
	{
		my $i = $m-1;
		if ($node->{children}->[$i])
		{
			$count += count_metadata2($node->{children}->[$i]);
		}
	}
	return $count;
}

sub count_metadata
{
	my ($node) = @_;

	my $count = 0;
	foreach my $m (@{$node->{metadata}})
	{
		$count += $m;
	}

	foreach my $c (@{$node->{children}})
	{
		$count += count_metadata($c);
	}
	return $count;
}


sub create_node
{
	my $node = {};
	my $child_count = shift @NUMBERS;
	my $metadata_count = shift @NUMBERS;

	$node->{children} = create_children($child_count);
	$node->{metadata} = create_metadata($metadata_count);

	return $node;
}

sub create_metadata
{
	my ($metadata_count) = @_;

	my $metadata = [];
	return $metadata unless $metadata_count; #no metadata

	foreach (1 .. $metadata_count)
	{
		push @{$metadata}, shift @NUMBERS;
	}
	return $metadata;
}

sub create_children
{
	my ($child_count) = @_;

	my $children = [];
	return $children unless $child_count; # no children;
	foreach (1 .. $child_count)
	{
		push @{$children}, create_node;
	}
	return $children;
}


sub get_input
{
	open FILE, "input.txt";
	my @input = <FILE>;
	return $input[0];
}

sub test_data
{
	return '2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2';

}
