#!/usr/bin/perl

use strict;
use warnings;
use Data::Compare;
use Data::Dumper;

my $REGISTERS = [ 0, 0, 0, 0 ];

my $OPS = {
	addr => sub
	{
		my ($a, $b, $c) = @_;

		validate_registers($a,$b,$c);
		$REGISTERS->[$c] = $REGISTERS->[$a] + $REGISTERS->[$b];
	},
	addi => sub
	{
		my ($a, $b, $c) = @_;

		validate_registers($a,$c);
		$REGISTERS->[$c] = $REGISTERS->[$a] + $b;
	},
	mulr => sub
	{
		my ($a, $b, $c) = @_;
		validate_registers($a,$b,$c);
		$REGISTERS->[$c] = $REGISTERS->[$a] * $REGISTERS->[$b];
	},
	muli => sub
	{
		my ($a, $b, $c) = @_;
		validate_registers($a,$c);
		$REGISTERS->[$c] = $REGISTERS->[$a] * $b;
	},
	banr => sub
	{
		my ($a, $b, $c) = @_;
		validate_registers($a,$b,$c);
		$REGISTERS->[$c] = $REGISTERS->[$a] & $REGISTERS->[$b];
	},
	bani => sub
	{
		my ($a, $b, $c) = @_;
		validate_registers($a,$c);

		$REGISTERS->[$c] = $REGISTERS->[$a] & $b;
	},
	borr => sub
	{
		my ($a, $b, $c) = @_;
		validate_registers($a,$b,$c);

		$REGISTERS->[$c] = $REGISTERS->[$a] | $REGISTERS->[$b];
	},
	bori => sub
	{
		my ($a, $b, $c) = @_;
		validate_registers($a,$c);
		$REGISTERS->[$c] = $REGISTERS->[$a] | $b;
	},
	setr => sub
	{
		my ($a, $b, $c) = @_;
		validate_registers($a,$c);
		$REGISTERS->[$c] = $REGISTERS->[$a];
	},
	seti => sub
	{
		my ($a, $b, $c) = @_;
		validate_registers($c);
		$REGISTERS->[$c] = $a;
	},
	gtir => sub
	{
		my ($a, $b, $c) = @_;
		validate_registers($b,$c);
		my $result = 0;
		$result = 1 if $a > $REGISTERS->[$b];
		$REGISTERS->[$c] = $result;
	},
	gtri => sub
	{
		my ($a, $b, $c) = @_;
		validate_registers($a,$c);
		my $result = 0;
		$result = 1 if $REGISTERS->[$a] > $b;
		$REGISTERS->[$c] = $result;
	},
	gtrr => sub
	{
		my ($a, $b, $c) = @_;
		validate_registers($a,$b,$c);
		my $result = 0;
		$result = 1 if $REGISTERS->[$a] > $REGISTERS->[$b];
		$REGISTERS->[$c] = $result;
	},
	eqir => sub
	{
		my ($a, $b, $c) = @_;
		validate_registers($b,$c);
		my $result = 0;
		$result = 1 if $a == $REGISTERS->[$b];
		$REGISTERS->[$c] = $result;
	},
	eqri => sub
	{
		my ($a, $b, $c) = @_;
		validate_registers($a,$c);
		my $result = 0;
		$result = 1 if $REGISTERS->[$a] == $b;
		$REGISTERS->[$c] = $result;
	},
	eqrr => sub
	{
		my ($a, $b, $c) = @_;
		validate_registers($a,$b,$c);
		my $result = 0;
		$result = 1 if $REGISTERS->[$a] == $REGISTERS->[$b];
		$REGISTERS->[$c] = $result;
	},
};

my @examples = load_examples();
my $count = 0;
my $i = 0;
foreach my $example (@examples)
{
	my $possible_opcodes = test_instruction($example->{before}, $example->{instruction}, $example->{after});

	my $opcode_count = scalar @{$possible_opcodes};
	$count++ if $opcode_count >= 3;
	$i++;
	print "$i: $opcode_count ($count) - " . join(',', sort @{$possible_opcodes}) . "\n";
}
print "$i $count\n";

sub test_instruction
{
	my ($register_before, $instruction, $register_after) = @_;

	my $ok_opcodes = [];

	foreach my $opcode (sort keys %{$OPS})
	{
		set_registers($register_before);

		my $fn = $OPS->{$opcode};

		eval {&{$fn}($instruction->[1], $instruction->[2], $instruction->[3]);};
		if ($@)
		{
			print STDERR "$opcode failed\n";
		}
		else
		{
			push @{$ok_opcodes}, $opcode if Compare($REGISTERS, $register_after); 
		}
#print STDERR "check $opcode: " . join(',',@{$register_before}) . " -> " . join(',',@{$instruction}) . " -> " . join(',',@{$REGISTERS}) . "(expecting " . join(',',@{$register_after}) . ")\n";
	}
#print STDERR join(',',@{$ok_opcodes}) . "\n";
	return $ok_opcodes;
}


sub set_registers
{
	my ($values) = @_;

	foreach my $i (0 .. 3)
	{
		$REGISTERS->[$i] = $values->[$i];
	}
}

sub validate_registers
{
	my (@register_addresses) = @_;

	foreach my $r (@register_addresses)
	{
		if ($r < 0 || $r > $#{$REGISTERS})
		{
			die "Out of bounds register address: $r\n";
		}
	}
}

sub load_examples
{
	open FILE, 'input.txt' or die "couldn't open input.txt\n";

	my @examples = ();

	my $example = {};
	while (my $line = <FILE>)
	{
		if ($line =~ m/^Before:\s*\[([0-9]+), ([0-9]+), ([0-9]+), ([0-9]+)\]/)
		{
			$example->{before} = [int $1,int $2,int $3,int $4];
		}
		if ($line =~ m/([0-9]+) ([0-9]+) ([0-9]+) ([0-9]+)/)
		{
			$example->{instruction} = [int $1,int $2,int $3,int $4];
		}
		if ($line =~ m/^After:\s*\[([0-9]+), ([0-9]+), ([0-9]+), ([0-9]+)\]/)
		{
			$example->{after} = [int $1,int $2,int $3,int $4];
			if (!$example->{after} || !$example->{before} || !$example->{instruction})
			{
				die "incomplete example\n";
			}


			push @examples, $example;
			$example = {};
		}
	}
	return @examples;
}


sub test_ops
{

	my $tests = 
	{
		addr => [
			[[0,5,3,1],[0,1,2,0],[8,5,3,1]]
		],
		addi => [
			[[0,5,3,1],[0,1,2,0],[7,5,3,1]]
		],
		mulr => [
			[[0,5,3,1],[0,1,2,0],[15,5,3,1]]
		],	
		muli => [
			[[0,5,3,1],[0,1,2,0],[10,5,3,1]]
		],
		banr => [
			[[0,5,3,1],[0,1,2,0],[1,5,3,1]]
		],
		bani => [
			[[0,5,3,1],[0,1,12,0],[4,5,3,1]]
		],
		borr => [
			[[0,5,3,1],[0,1,2,0],[7,5,3,1]]
		],
		bori => [
			[[0,5,3,1],[0,1,12,0],[13,5,3,1]]
		],
		setr => [
			[[0,5,3,1],[0,1,2,0],[5,5,3,1]]
		],
		seti => [
			[[0,5,3,1],[0,1,2,0],[1,5,3,1]]
		],
		gtir => [
			[[2,5,3,1],[0,1,2,0],[0,5,3,1]],
			[[2,5,3,1],[0,7,2,0],[1,5,3,1]]
		],
		gtri => [
			[[2,5,3,1],[0,1,7,0],[0,5,3,1]],
			[[2,5,3,1],[0,1,2,0],[1,5,3,1]]
		],
		gtrr => [
			[[2,5,3,1],[0,1,7,0],[0,5,3,1]],
			[[2,5,3,1],[0,1,2,0],[1,5,3,1]]
		],
	
	};

	foreach my $opcode (keys %{$tests})
	{
		print STDERR "Testing $opcode\n";
		foreach my $test (@{$tests->{$opcode}})
		{
			my ($before, $instruction, $after) = @{$test};

			set_registers($before);
			&{$OPS->{$opcode}}($instruction->[1],$instruction->[2], $instruction->[3]);
			if (Compare($REGISTERS, $after))
			{
				print STDERR "OK\n";
			}
			else
			{
				use Data::Dumper;
				print STDERR "Test Failed";
				print STDERR Dumper $test;
				print STDERR Dumper $REGISTERS;
			}
		}
	}

}

