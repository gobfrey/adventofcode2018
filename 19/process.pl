#!/usr/bin/perl

use strict;
use warnings;
use Data::Compare;
use Data::Dumper;

my $REGISTERS = [ 0, 0, 0, 0, 0, 0 ];
my $IP_REGISTER;

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




set_registers([1,0,0,0,0,0]);



my @program = load_program();

my $i = 1;
while (1)
{
	my $ip = ip();

	print "$i ";
	print sprintf("ip = %02d ",$ip);;
	output_registers();

	last if ($ip < 0);
	last if ($ip > $#program);

	my $inst = @program[ip()];

	print ' ' . $inst->[0] . " " , join(' ', @{$inst->[1]}) . ' ';

	execute_instruction($inst);

	output_registers();

	print "\n";

	increment_ip();

	if ($REGISTERS->[4] == 1) { $REGISTERS->[4] = $REGISTERS->[5] - 1};
	$i++;

#	sleep(1);
}

print "\n", join(',',@{$REGISTERS}) . "\n";


sub output_registers
{
	print '[';

	my @nums = ();

	foreach my $r (@{$REGISTERS})
	{
		push @nums, sprintf("%03d", $r);
	}
	print join(',',@nums);
	print ']';
}

sub execute_instruction
{
	my ($inst) = @_;

	my $fn = $OPS->{$inst->[0]};
	&{$fn}(@{$inst->[1]});
}

sub ip
{
	return $REGISTERS->[$IP_REGISTER];
}

sub increment_ip
{
	my $ip = $REGISTERS->[$IP_REGISTER];
	$REGISTERS->[$IP_REGISTER] = $ip+1;
}


sub set_registers
{
	my ($values) = @_;

	foreach my $i (0 .. $#{$values})
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

sub load_program
{
	my @lines = load_file();

	my @program = ();

	my $instruction = undef;
	foreach my $line (@lines)
	{
		if ($line =~ m/^#ip ([0-9])/)
		{
print STDERR "Setting IP Register\n";
			$IP_REGISTER = $1;
			next;
		}
		my ($instruction, $a, $b, $c) = split(/\s/, $line);

		push @program, [ $instruction, [int $a, int $b, int $c] ];
	}
	return @program;
}


sub load_file
{
	open FILE, 'input.txt' or die "couldn't open input.txt\n";
	return <FILE>;
}

sub load_test_data
{
	return split(/\n/,'#ip 0
seti 5 0 1
seti 6 0 2
addi 0 1 0
addr 1 2 3
setr 1 0 0
seti 8 0 4
seti 9 0 5');
}

