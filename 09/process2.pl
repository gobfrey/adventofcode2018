#!/usr/bin/perl

use strict;
use warnings;


my $number_of_players = 459;
my $last_marble = 7210300;

#first  moves
my $ACTIVE;
my $NEXT_MARBLE = 0;
my %SCORES = ();

GAME: while (1)
{
	print STDERR "$NEXT_MARBLE\n";
	foreach my $player (1 .. $number_of_players)
	{
		last GAME if $NEXT_MARBLE > $last_marble;
		play_move($player);
#		output_board();
	}
}


my @ranked_scores = reverse sort values %SCORES;
print $ranked_scores[0] . "\n";

sub output_board
{
	my $marble = $ACTIVE;

	while (!$marble->{first})
	{
		$marble = $marble->{next};
	}

	while (!$marble->{next}->{first})
	{
		if ($marble == $ACTIVE)
		{
			print STDERR '(' . $marble->{value} . ')';
		}
		else
		{
			print STDERR ' ' . $marble->{value} . ' ';
		}
		$marble = $marble->{next};
	}
	print STDERR "\n";
}

sub play_move
{
	my ($player) = @_;

	my $marble = get_next_marble();

	if ($marble->{value} == 0)
	{
		$marble->{next} = $marble;
		$marble->{previous} = $marble;
		$marble->{first} = 1;
		$ACTIVE = $marble;
	}
	elsif ($marble->{value} % 23 == 0)
	{
		for (1 .. 6)
		{
			$ACTIVE = $ACTIVE->{previous};
		}
		my $to_remove = $ACTIVE->{previous};

		$SCORES{$player} += $to_remove->{value};
		$SCORES{$player} += $marble->{value};
		remove($to_remove);
	}
	else
	{
		#insert two to the right;

		$ACTIVE = $ACTIVE->{next};

		insert_as_next($ACTIVE, $marble);

		$ACTIVE = $marble;
	}
}

sub insert_as_next
{
	my ($node, $new_node) = @_;

	my $next = $node->{next};

	$next->{previous} = $new_node;
	$node->{next} = $new_node;

	$new_node->{next} = $next;
	$new_node->{previous} = $node;
}

sub remove
{
	my ($node) = @_;

	my $prev = $node->{previous};
	my $next = $node->{next};

	if ($node->{first})
	{
		$next->{first} = 1;
	}

	$prev->{next} = $next;
	$next->{previous} = $prev;

	$ACTIVE = $next;
}

sub get_next_marble
{
	my $m = $NEXT_MARBLE;
	$NEXT_MARBLE++;
	return { value => $m, next => '', previous => '' } ;
}



