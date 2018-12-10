#!/usr/bin/perl

use strict;
use warnings;
use Date::Calc qw(Add_Delta_DHMS);

open FILE, "input.txt";

my @input = <FILE>;

#@input = test_data();

my $dependencies = {};
my $reverse_dependencies = {};

foreach my $line (@input)
{
	if ($line =~ m/Step ([A-Z]) .* ([A-Z])/)
	{
		push @{$dependencies->{$1}}, $2;
		push @{$reverse_dependencies->{$2}}, $1;
	}
}


my @ALL_TASKS = all_labels($dependencies);
my %TASKS;
my $i = 1;
foreach my $t (@ALL_TASKS)
{
	$TASKS{$t} =
	{
		duration => 60 + $i,
		time_started => undef,
	 };
	if ($reverse_dependencies->{$t})
	{
		$TASKS{$t}->{dependant_on} = $reverse_dependencies->{$t};
	}
	else
	{
		$TASKS{$t}->{dependant_on} = [];
	}
	$i++;
}

my @workers = ( undef, undef, undef, undef, undef);

my $t = 0;
while (1)
{
	print STDERR "$t seconds\n";
	for my $i (0 .. $#workers)
	{
		if (worker_is_idle($workers[$i]))
		{
			$workers[$i] = get_next_task();
			print STDERR "Assigned task to worker $i\n";
			use Data::Dumper;
			print STDERR Dumper \@workers;
		}
	}
	last if (all_work_done());

	$t++;

}

print "$t\n";

sub worker_is_idle
{
	my ($task) = @_;

	return 1 if !$task;
	return 0 if task_is_ongoing($task);
	return 1;
}

sub all_work_done
{
	
	foreach my $task (values %TASKS)
	{
		return 0 if !task_is_done($task);
	}
	return 1;
}

sub get_next_task
{
	foreach my $task_id (sort keys %TASKS)
	{
		my $task = $TASKS{$task_id};
		next if task_is_done($task);
		next if task_is_ongoing($task);
		if (task_is_ready($task))
		{
			$task->{time_started} = $t;
			return $task;
		}
	}
	return undef;
}

sub task_is_ongoing
{
	my ($task) = @_;

	return 0 unless defined $task->{time_started};
	return 1 if $t < $task->{time_started} + $task->{duration};
	return 0;
}

sub task_is_ready
{
	my ($task) = @_;

	my $preceeding_tasks = $task->{dependant_on};
	return 1 unless $preceeding_tasks; #no dependencies

	foreach my $preceeding_task (@{$preceeding_tasks})
	{
		return 0 if !task_is_done($preceeding_task);
	}
	return 1;
}

sub task_is_done
{
	my ($task) = @_;

	if (!ref $task)
	{
		$task = $TASKS{$task};
	}

	return 0 unless defined $task->{time_started};
	return 1 if $t >= $task->{time_started} + $task->{duration};
	return 0;
}


sub all_labels
{
	my ($dependencies) = @_;

	my $labels = {};

	foreach my $k (keys %{$dependencies})
	{
		$labels->{$k} = 1;
		foreach my $target (@{$dependencies->{$k}})
		{
			$labels->{$target} = 1;
		}
	}

	my @all_labels = sort keys %{$labels};
	return @all_labels
}

sub test_data
{
	return (
'Step C must be finished before step A can begin.',
'Step C must be finished before step F can begin.',
'Step A must be finished before step B can begin.',
'Step A must be finished before step D can begin.',
'Step B must be finished before step E can begin.',
'Step D must be finished before step E can begin.',
'Step F must be finished before step E can begin.'
);

}
