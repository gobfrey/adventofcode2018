#!/usr/bin/perl

use strict;
use warnings;


my $number_of_players = 459;
my $last_marble = 72103;

#first  moves
my @CIRCLE = ( );
my $ACTIVE;
my $NEXT_MARBLE = 0;
my %SCORES = ();



GAME: while (1)
{
	print STDERR $NEXT_MARBLE . "\n";
	foreach my $player (1 .. $number_of_players)
	{
		last GAME if $NEXT_MARBLE > $last_marble;
		play_move($player);
#		output_board();
	}
}


my @ranked_scores = reverse sort values %SCORES;
print $ranked_scores[0] . "\n";

sub play_move
{
	my ($player) = @_;

	my $marble = get_next_marble();

	if ($marble == 0 || $marble == 1) #first two moves are done by hand
	{
		add_at_index($marble, $marble);
	}
	elsif ($marble % 23 == 0)
	{
		$SCORES{$player} += $marble;


		my $new_active = circular_index('left', 7);
		my $removed_marble = remove_at_index($new_active);
		$ACTIVE = $new_active;
		$SCORES{$player} += $removed_marble;
	}
	else
	{
		add_at_index(circular_index('right',2), $marble)
	}
}

sub get_next_marble
{
	my $m = $NEXT_MARBLE;
	$NEXT_MARBLE++;
	return $m;
}

sub add_at_index
{
	my ($i, $marble) = @_;

	$ACTIVE = $i;
	if ($i == 0)
	{
		unshift @CIRCLE, $marble;
	}
	elsif ($i == $#CIRCLE+1)
	{
		push @CIRCLE, $marble;
	}
	else
	{
		splice @CIRCLE, $i, 0, $marble;
	}
}

sub remove_at_index
{
	my ($i) = @_;

	if ($ACTIVE > $i)
	{
		$ACTIVE--;
	}

	return splice(@CIRCLE, $i, 1);
}


sub circular_index
{
	my ($direction,$offset) = @_; #positive int for clockwise, negative for anticlockwise;

	
	my $new_index = $ACTIVE + $offset;
	if ($direction eq 'left')
	{
		$new_index = $ACTIVE - $offset;
	}

	if ($new_index > $#CIRCLE)
	{
		$new_index = ($new_index - $#CIRCLE) - 1;
	}

	if ($new_index < 0)
	{
		$new_index = ($#CIRCLE + $new_index) + 1;
	}
	return $new_index;
}


sub output_board
{
	foreach my $pos (0 .. $#CIRCLE)
	{
		if ($pos == $ACTIVE)
		{
			print sprintf("(%03d)", $CIRCLE[$pos]);
		}
		else
		{
			print sprintf(" %03d ", $CIRCLE[$pos]);
		}
	}
	print "\n";
}



sub test_circular_index
{
	@CIRCLE = 0 .. 100;

	$ACTIVE = 2;
	my $i = circular_index('left', 7);
	print STDERR "$i should be 96\n";


}
